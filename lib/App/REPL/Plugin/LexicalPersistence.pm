package App::REPL::Plugin::LexicalPersistence;
use strict;
use warnings;

use base 'App::REPL::Plugin';

use Lexical::Persistence;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{env} = Lexical::Persistence->new;
    return $self;
}

sub evaluate {
    my $self = shift;
    my ($next, $line, %args) = @_;

    $line = $self->{env}->prepare($line);
    my ($code) = $next->($line, %args);
    return $self->{env}->call($code);
}

1;
