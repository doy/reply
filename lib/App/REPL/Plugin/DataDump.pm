package App::REPL::Plugin::DataDump;
use strict;
use warnings;

use base 'App::REPL::Plugin';

use Data::Dump 'pp';

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return @result ? pp(@result) : ();
}

1;
