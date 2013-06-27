package Reply::Plugin::Autocomplete;
use strict;
use warnings;
# ABSTRACT: tab complete your input

use base 'Reply::Plugin';

use B::Keywords qw/@Functions @Barewords/;

=head1 SYNOPSIS

  ; .replyrc
  [Autocomplete]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete Perl code.

=cut

sub tab_handler {
    my ($self, $line) = @_;

    return (
        $self->_tab_keyword($line),
    );
}

sub _tab_keyword {
    my ($self, $line) = @_;

    my ($last_word) = $line =~ /(\w+)$/;
    return unless $last_word;

    my $re = qr/^\Q$last_word/;

    return grep { $_ =~ $re } @Functions, @Barewords;
}

1;
