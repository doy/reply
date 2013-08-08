package main;
use strict;
use warnings;
# ABSTRACT: format results using Data::Printer

use mop;

use Data::Printer alias => 'p', colored => 1;

=head1 SYNOPSIS

  ; .replyrc
  [DataPrinter]

=head1 DESCRIPTION

This plugin uses L<Data::Printer> to format results.

=cut

class Reply::Plugin::DataPrinter extends Reply::Plugin {
    method mangle_result (@result) {
        return p(@result, return_value => 'dump');
    }
}

1;
