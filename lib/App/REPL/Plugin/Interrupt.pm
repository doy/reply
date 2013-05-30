package App::REPL::Plugin::Interrupt;
use strict;
use warnings;

use base 'App::REPL::Plugin';

sub evaluate {
    my $self = shift;
    my ($next, $line, %args) = @_;

    local $SIG{INT} = sub { die "Interrupted" };
    $next->($line, %args);
}

1;
