package Reply::Plugin::DataDumper;
use strict;
use warnings;
# ABSTRACT: format results using Data::Dumper

use base 'Reply::Plugin';

use Data::Dumper;

=head1 SYNOPSIS

  ; .replyrc
  [DataDumper]
  respect_freeze = 0

=head1 DESCRIPTION

This plugin uses L<Data::Dumper> to format results.

You can enable C<respect_freeze> feature to force L<Data::Dumper> call
C<freeze> method to retrieve object suitable for dumping.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    $Data::Dumper::Terse = 1;
    $Data::Dumper::Sortkeys = 1;
    $Data::Dumper::Freezer = 'freeze' if $opts{respect_freeze};

    return $class->SUPER::new(@_);
}

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return Dumper(@result == 0 ? () : @result == 1 ? $result[0] : \@result);
}

1;
