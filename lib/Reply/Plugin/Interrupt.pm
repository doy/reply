package main;
use strict;
use warnings;
# ABSTRACT: allows using Ctrl+C to interrupt long-running lines

use mop;

=head1 SYNOPSIS

  ; .replyrc
  [Interrupt]

=head1 DESCRIPTION

This plugin allows you to use Ctrl+C to interrupt long running commands without
exiting the Reply shell entirely.

=cut

class Reply::Plugin::Interrupt extends Reply::Plugin {
    method compile ($next, @args) {
        local $SIG{INT} = sub { die "Interrupted" };
        $next->(@args);
    }

    method execute ($next, @args) {
        local $SIG{INT} = sub { die "Interrupted" };
        $next->(@args);
    }
}

1;
