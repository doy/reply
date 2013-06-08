package Reply::Plugin::FancyPrompt;
use strict;
use warnings;
# ABSTRACT: provides a more informative prompt

use base 'Reply::Plugin';

=head1 SYNOPSIS

  ; .replyrc
  [FancyPrompt]

=head1 DESCRIPTION

This plugin enhances the default Reply prompt. Currently, the only difference
is that it includes a counter of the number of lines evaluated so far in the
current session.

=cut

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{counter} = 0;
    $self->{prompted} = 0;
    return $self;
}

sub prompt {
    my $self = shift;
    my ($next) = @_;
    $self->{prompted} = 1;
    return $self->{counter} . $next->();
}

sub loop {
    my $self = shift;
    my ($continue) = @_;
    $self->{counter}++ if $self->{prompted};
    $self->{prompted} = 0;
    $continue;
}

1;
