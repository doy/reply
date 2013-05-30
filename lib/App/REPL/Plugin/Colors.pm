package App::REPL::Plugin::Colors;
use strict;
use warnings;

use base 'App::REPL::Plugin';

use Term::ANSIColor;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{error} = 'red';
    $self->{warning} = 'yellow';
    $self->{result} = 'green';

    return $self;
}

sub evaluate {
    my $self = shift;
    my ($next, @args) = @_;

    local $SIG{__WARN__} = sub { $self->print_warn(@_) };
    $next->(@args);
}

sub print_error {
    my $self = shift;
    my ($next, $error) = @_;

    print color($self->{error});
    $next->($error);
    local $| = 1;
    print color('reset');
}

sub print_result {
    my $self = shift;
    my ($next, @result) = @_;

    print color($self->{result});
    $next->(@result);
    local $| = 1;
    print color('reset');
}

sub print_warn {
    my $self = shift;
    my ($warning) = @_;

    print color($self->{warning});
    print $warning;
    local $| = 1;
    print color('reset');
}

1;
