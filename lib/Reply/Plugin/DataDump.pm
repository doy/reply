package Reply::Plugin::DataDump;
use strict;
use warnings;
# ABSTRACT: format results using Data::Dump

use base 'Reply::Plugin';

use Data::Dump 'pp';

=head1 SYNOPSIS

  ; .replyrc
  [DataDumper]

=head1 DESCRIPTION

This plugin uses L<Data::Dump> to format results.

=cut

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return @result ? pp(@result) : ();
}

1;
