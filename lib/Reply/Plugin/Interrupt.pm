package Reply::Plugin::Interrupt;
use strict;
use warnings;

use base 'Reply::Plugin';

sub compile {
    my $self = shift;
    my ($next, @args) = @_;

    local $SIG{INT} = sub { die "Interrupted" };
    $next->(@args);
}

sub execute {
    my $self = shift;
    my ($next, @args) = @_;

    local $SIG{INT} = sub { die "Interrupted" };
    $next->(@args);
}

1;
