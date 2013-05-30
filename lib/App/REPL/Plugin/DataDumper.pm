package App::REPL::Plugin::DataDumper;
use strict;
use warnings;

use base 'App::REPL::Plugin';

use Data::Dumper;

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return Dumper(@result);
}

1;
