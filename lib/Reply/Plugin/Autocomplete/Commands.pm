package Reply::Plugin::Autocomplete::Commands;
use strict;
use warnings;

use base 'Reply::Plugin';

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($prefix) = $line =~ /^#(.*)/;
    return unless defined $prefix;

    my @commands = $self->publish('commands');

    return map { "#$_" } sort grep { index($_, $prefix) == 0 } @commands;
}

1;
