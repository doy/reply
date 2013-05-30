package Reply;
use strict;
use warnings;
# ABSTRACT: read, eval, print, loop, yay!

use Config::INI::Reader::Ordered;
use Module::Runtime qw(compose_module_name use_package_optimistically);
use Scalar::Util qw(blessed);
use Try::Tiny;

sub new {
    my $class = shift;
    my %opts = @_;

    require Reply::Plugin::Defaults;
    my $self = bless {
        plugins         => [],
        _default_plugin => Reply::Plugin::Defaults->new,
    }, $class;

    $self->load_plugin($_) for @{ $opts{plugins} || [] };

    if (defined $opts{config}) {
        print "Loading configuration from $opts{config}... ";
        $self->load_config($opts{config});
        print "done\n";
    }

    return $self;
}

sub load_plugin {
    my $self = shift;
    my ($plugin, $opts) = @_;

    if (!blessed($plugin)) {
        $plugin = compose_module_name("Reply::Plugin", $plugin);
        use_package_optimistically($plugin);
        die "$plugin is not a valid plugin"
            unless $plugin->isa("Reply::Plugin");
        $plugin = $plugin->new(%$opts);
    }

    push @{ $self->{plugins} }, $plugin;
}

sub load_config {
    my $self = shift;
    my ($file) = @_;

    my $data = Config::INI::Reader::Ordered->new->read_file($file);

    my $root_config;
    for my $section (@$data) {
        my ($name, $data) = @$section;
        if ($name eq '_') {
            $root_config = $data;
        }
        else {
            $self->load_plugin($name => $data);
        }
    }

    for my $line (sort grep { /^script_line/ } keys %$root_config) {
        $self->_eval($root_config->{$line});
    }

    if (defined(my $file = $root_config->{script_file})) {
        my $contents = do {
            open my $fh, '<', $file or die "Couldn't open $file: $!";
            local $/ = undef;
            <$fh>
        };
        $self->_eval($contents);
    }
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

    if (defined($line) && $line =~ s/^#(\w+)(?:\s+|$)//) {
        ($line) = $self->_chained_plugin("command_\L$1", $line);
    }

    return $line;
}

sub _eval {
    my $self = shift;
    my ($line) = @_;

    ($line) = $self->_chained_plugin('mangle_line', $line)
        if defined $line;

    my ($code) = $self->_wrapped_plugin('compile', $line);
    return $self->_wrapped_plugin('execute', $code);
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
