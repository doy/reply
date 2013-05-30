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

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    my %c = %{ $self->{env}->get_context('_') };

    $args{environment} ||= {};
    $args{environment} = {
        %{ $args{environment} },
        (map { $_ => ref($c{$_}) ? $c{$_} : \$c{$_} } keys %c),
    };
    my ($code) = $next->($line, %args);
    return $self->{env}->wrap($code);
}

1;
