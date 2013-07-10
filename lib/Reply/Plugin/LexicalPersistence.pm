package Reply::Plugin::LexicalPersistence;
use strict;
use warnings;
# ABSTRACT: persists lexical variables between lines

use base 'Reply::Plugin';

use PadWalker 'peek_sub';

=head1 SYNOPSIS

  ; .replyrc
  [LexicalPersistence]

=head1 DESCRIPTION

This plugin persists the values of lexical variables between input lines. For
instance, with this plugin you can enter C<my $x = 2> into the Reply shell, and
then use C<$x> as expected in subsequent lines.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{env} = {};

    return $self;
}

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    my ($code) = $next->($line, %args);

    $self->{env} = {
        %{ $self->{env} },
        %{ peek_sub($code) },
    };

    return $code;
}

sub lexical_environment {
    my $self = shift;

    return $self->{env};
}

1;
