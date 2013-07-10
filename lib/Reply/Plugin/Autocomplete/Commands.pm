package Reply::Plugin::Autocomplete::Commands;
use strict;
use warnings;
# ABSTRACT: tab completion for reply commands

use base 'Reply::Plugin';

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Commands]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete Reply commands.

=cut

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($prefix) = $line =~ /^#(.*)/;
    return unless defined $prefix;

    my @commands = $self->publish('commands');

    return map { "#$_" } sort grep { index($_, $prefix) == 0 } @commands;
}

1;
