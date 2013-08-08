package main;
use strict;
use warnings;
# ABSTRACT: tab completion for perl keywords

use mop;

use B::Keywords qw/@Functions @Barewords/;

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Keywords]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete keywords in Perl code.

=cut

class Reply::Plugin::Autocomplete::Keywords extends Reply::Plugin {
    method tab_handler ($line) {
        my ($before, $last_word) = $line =~ /(.*?)(\w+)$/;
        return unless $last_word;
        return if $before =~ /^#/; # command
        return if $before =~ /::$/; # Package::function call
        return if $before =~ /->\s*$/; # method call
        return if $before =~ /[\$\@\%\&\*]\s*$/;

        my $re = qr/^\Q$last_word/;

        return grep { $_ =~ $re } @Functions, @Barewords;
    }
}

1;
