package main;
use strict;
use warnings;
# ABSTRACT: persists lexical variables between lines

use mop;

use PadWalker 'peek_sub', 'closed_over';

=head1 SYNOPSIS

  ; .replyrc
  [LexicalPersistence]

=head1 DESCRIPTION

This plugin persists the values of lexical variables between input lines. For
instance, with this plugin you can enter C<my $x = 2> into the Reply shell, and
then use C<$x> as expected in subsequent lines.

=cut

class Reply::Plugin::LexicalPersistence extends Reply::Plugin {
    has $!env = {};

    method compile ($next, $line, %args) {
        my ($code) = $next->($line, %args);

        my $new_env = peek_sub($code);
        delete $new_env->{$_} for keys %{ closed_over($code) };

        $!env = { %{$!env}, %$new_env };

        return $code;
    }

    method lexical_environment { $!env }
}

1;
