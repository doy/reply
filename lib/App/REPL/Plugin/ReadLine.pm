package App::REPL::Plugin::ReadLine;
use strict;
use warnings;

use base 'App::REPL::Plugin';

use Term::ReadLine;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{term} = Term::ReadLine->new('App::REPL');

    return $self;
}

sub read_line {
    my $self = shift;
    my ($next, $prompt) = @_;

    return $self->{term}->readline($prompt);
}

1;
