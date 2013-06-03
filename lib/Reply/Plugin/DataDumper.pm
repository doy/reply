package Reply::Plugin::DataDumper;
use strict;
use warnings;
# ABSTRACT: format results using Data::Dumper

use base 'Reply::Plugin';

use Data::Dumper;

=head1 SYNOPSIS

  ; .replyrc
  [DataDumper]

=head1 DESCRIPTION

This plugin uses L<Data::Dumper> to format results.

=cut

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return Dumper(@result);
}

1;
