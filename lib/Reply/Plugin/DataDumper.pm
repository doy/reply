package Reply::Plugin::DataDumper;
use strict;
use warnings;

use base 'Reply::Plugin';

use Data::Dumper;

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return Dumper(@result);
}

1;
