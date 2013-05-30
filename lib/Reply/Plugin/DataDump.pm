package Reply::Plugin::DataDump;
use strict;
use warnings;

use base 'Reply::Plugin';

use Data::Dump 'pp';

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return @result ? pp(@result) : ();
}

1;
