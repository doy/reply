package main;
use strict;
use warnings;
# ABSTRACT: provides a more informative prompt

use mop;

=head1 SYNOPSIS

  ; .replyrc
  [FancyPrompt]

=head1 DESCRIPTION

This plugin enhances the default Reply prompt. Currently, the only difference
is that it includes a counter of the number of lines evaluated so far in the
current session.

=cut

class Reply::Plugin::FancyPrompt extends Reply::Plugin {
    has $!counter  = 0;
    has $!prompted = 0;

    method prompt ($next) {
        $!prompted = 1;
        return $!counter . $next->();
    }

    method loop ($continue) {
        $!counter++ if $!prompted;
        $!prompted = 0;
        $continue;
    }
}

1;
