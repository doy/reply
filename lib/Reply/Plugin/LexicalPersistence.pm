package Reply::Plugin::LexicalPersistence;
use strict;
use warnings;

use base 'Reply::Plugin';

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
    $code = $self->_fixup_code($code, \%c);
    return $self->{env}->wrap($code);
}

# XXX this is maybe a bug in Lexical::Persistence - it clears variables that
# aren't in its context, regardless of if they may have been set elsewhere
sub _fixup_code {
    my $self = shift;
    my ($code, $context) = @_;

    require PadWalker;
    require Devel::LexAlias;

    my $pad = PadWalker::peek_sub($code);
    my %restore;
    for my $var (keys %$pad) {
        next unless $var =~ /^\$\@\%./;
        next if exists $context->{$var};
        $restore{$var} = $pad->{$var};
    }

    $self->{code} = $code;

    return sub {
        my $code = shift;
        for my $var (keys %restore) {
            Devel::LexAlias::lexalias($code, $var, $restore{$var});
        }
        $code->(@_);
    };
}

# XXX can't just close over $code, because it will also be cleared by the same
# bug! we have to pass it as a parameter instead
sub execute {
    my $self = shift;
    my ($next, @args) = @_;

    $next->(delete $self->{code}, @args);
}

1;
