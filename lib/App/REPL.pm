package App::REPL;
use strict;
use warnings;

use Module::Runtime qw(compose_module_name use_package_optimistically);
use Scalar::Util qw(blessed);
use Try::Tiny;

sub new {
    my $class = shift;
    my %opts = @_;

    require App::REPL::Plugin::Defaults;
    my $self = bless {
        plugins         => [],
        _default_plugin => App::REPL::Plugin::Defaults->new,
    }, $class;

    my @plugins;
    my $postlude;
    if (exists $opts{script}) {
        my $script = do {
            open my $fh, '<', $opts{script}
                or die "Can't open $opts{script}: $!";
            local $/ = undef;
            <$fh>
        };
        local *main::load_plugin = sub {
            push @plugins, @_;
        };
        local *main::postlude = sub {
            $postlude .= $_[0];
        };
        print "Loading configuration from $opts{script}... ";
        $self->_eval($script);
        print "done\n";
    }

    $self->load_plugin($_) for @{ $opts{plugins} || [] }, @plugins;

    if (defined $postlude) {
        $self->_eval($postlude);
    }

    return $self;
}

sub load_plugin {
    my $self = shift;
    my ($plugin) = @_;

    if (!blessed($plugin)) {
        $plugin = compose_module_name("App::REPL::Plugin", $plugin);
        use_package_optimistically($plugin);
        die "$plugin is not a valid plugin"
            unless $plugin->isa("App::REPL::Plugin");
        $plugin = $plugin->new;
    }

    push @{ $self->{plugins} }, $plugin;
}

sub plugins {
    my $self = shift;

    return (
        @{ $self->{plugins} },
        $self->{_default_plugin},
    );
}

sub run {
    my $self = shift;

    while (defined(my $line = $self->_read)) {
        try {
            my @result = $self->_eval($line);
            $self->_print_result(@result);
        }
        catch {
            $self->_print_error($_);
        }
    }
    print "\n";
}

sub _read {
    my $self = shift;

    my $prompt = $self->_wrapped_plugin('prompt');
    my ($line) = $self->_wrapped_plugin('read_line', $prompt);

    return $line;
}

sub _eval {
    my $self = shift;
    my ($line) = @_;

    ($line) = $self->_chained_plugin('mangle_line', $line)
        if defined $line;

    return $self->_wrapped_plugin('evaluate', $line);
}

sub _print_error {
    my $self = shift;
    my ($error) = @_;

    ($error) = $self->_chained_plugin('mangle_error', $error);
    $self->_wrapped_plugin('print_error', $error);
}

sub _print_result {
    my $self = shift;
    my (@result) = @_;

    @result = $self->_chained_plugin('mangle_result', @result);
    $self->_wrapped_plugin('print_result', @result);
}

sub _wrapped_plugin {
    my $self = shift;
    my @plugins = ref($_[0]) ? @{ shift() } : $self->plugins;
    my ($method, @args) = @_;

    @plugins = grep { $_->can($method) } @plugins;

    return @args unless @plugins;

    my $plugin = shift @plugins;
    my $next = sub { $self->_wrapped_plugin(\@plugins, $method, @_) };

    return $plugin->$method($next, @args);
}

sub _chained_plugin {
    my $self = shift;
    my @plugins = ref($_[0]) ? @{ shift() } : $self->plugins;
    my ($method, @args) = @_;

    @plugins = grep { $_->can($method) } @plugins;

    for my $plugin (@plugins) {
        @args = $plugin->$method(@args);
    }

    return @args;
}

1;
