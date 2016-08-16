package Reply::Plugin::DataPrinter;
use strict;
use warnings;
# ABSTRACT: format results using Data::Printer

use base 'Reply::Plugin';

use Data::Printer alias => 'p', colored => 1, return_value => 'dump';

=head1 SYNOPSIS

  ; .replyrc
  [DataPrinter]

=head1 DESCRIPTION

This plugin uses L<Data::Printer> to format results.

=cut

sub mangle_result {
    my ($self, @result) = @_;
    return unless @result;
    ( @result == 1 ) && return p($result[0]);
    return p(@result);
}

1;
