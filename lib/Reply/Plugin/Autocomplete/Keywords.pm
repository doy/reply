package Reply::Plugin::Autocomplete::Keywords;
use strict;
use warnings;
# ABSTRACT: tab completion for perl keywords

use base 'Reply::Plugin';

use B::Keywords qw/@Functions @Barewords/;

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Keywords]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete keywords in Perl code.

=cut

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($last_word) = $line =~ /(\w+)$/;
    return unless $last_word;

    my $re = qr/^\Q$last_word/;

    return grep { $_ =~ $re } @Functions, @Barewords;
}

=for Pod::Coverage
  tab_handler

=cut

1;
