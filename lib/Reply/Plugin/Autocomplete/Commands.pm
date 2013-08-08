package main;
use strict;
use warnings;
# ABSTRACT: tab completion for reply commands

use mop;

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Commands]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete Reply commands.

=cut

class Reply::Plugin::Autocomplete::Commands extends Reply::Plugin {
    method tab_handler ($line) {
        my ($prefix) = $line =~ /^#(.*)/;
        return unless defined $prefix;

        my @commands = $self->publish('commands');

        return map { "#$_" } sort grep { index($_, $prefix) == 0 } @commands;
    }
}

1;
