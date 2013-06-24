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

sub new {
    my $class = shift;

    $Data::Dumper::Terse = 1;
    $Data::Dumper::Sortkeys = 1;

    return $class->SUPER::new(@_);
}

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return Dumper(@result == 0 ? () : @result == 1 ? $result[0] : \@result);
}

1;
