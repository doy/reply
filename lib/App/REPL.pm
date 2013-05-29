package App::REPL;
use strict;
use warnings;

use App::REPL::Plugin::Defaults;

sub new {
    bless {
        plugins => [
            App::REPL::Plugin::Defaults->new,
        ]
    }, shift;
}

sub run {
    my $self = shift;

    while (defined(my $line = $self->_read)) {
        my @result = $self->_eval($line);
        $self->_print(@result);
    }
    print "\n";
}

sub _read {
    my $self = shift;

    $self->_wrapped_plugin('display_prompt');
    my ($line) = $self->_wrapped_plugin('read_line');
    ($line) = $self->_chained_plugin('munge_line', $line);

    return $line;
}

sub _eval {
    my $self = shift;
    my ($line) = @_;

    return $self->_wrapped_plugin('evaluate', $line);
}

sub _print {
    my $self = shift;
    my (@result) = @_;

    @result = $self->_chained_plugin('munge_result', @result);
    $self->_wrapped_plugin('print_result', @result);
}

sub _wrapped_plugin {
    my $self = shift;
    my $plugins = ref($_[0]) ? pop : $self->{plugins};
    my ($method, @args) = @_;

    $plugins = [ grep { $_->can($method) } @$plugins ];

    return @args unless @$plugins;

    my $plugin = shift @$plugins;
    my $next = sub { $self->_wrapped_plugin($plugins, @_) };

    return $plugin->$method($next, @args);
}

sub _chained_plugin {
    my $self = shift;
    my $plugins = ref($_[0]) ? pop : $self->{plugins};
    my ($method, @args) = @_;

    $plugins = [ grep { $_->can($method) } @$plugins ];

    for my $plugin (@$plugins) {
        @args = $plugin->$method(@args);
    }

    return @args;
}

1;
