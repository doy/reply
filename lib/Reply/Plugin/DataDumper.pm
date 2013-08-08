package main;
use strict;
use warnings;
# ABSTRACT: format results using Data::Dumper

use mop;

use Data::Dumper;

=head1 SYNOPSIS

  ; .replyrc
  [DataDumper]

=head1 DESCRIPTION

This plugin uses L<Data::Dumper> to format results.

=cut

class Reply::Plugin::DataDumper extends Reply::Plugin {
    submethod BUILD {
        $Data::Dumper::Terse = 1;
        $Data::Dumper::Sortkeys = 1;
    }

    method mangle_result (@result) {
        return Dumper(@result == 0 ? () : @result == 1 ? $result[0] : \@result);
    }
}

1;
