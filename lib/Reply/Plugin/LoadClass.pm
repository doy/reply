package Reply::Plugin::LoadClass;
use strict;
use warnings;

use base 'Reply::Plugin';

use Module::Runtime 'use_package_optimistically';
use Try::Tiny;

sub execute {
    my $self = shift;
    my ($next, @args) = @_;

    try {
        $next->(@args);
    }
    catch {
        if (/^Can't locate object method "[^"]*" via package "([^"]*)"/) {
            use_package_optimistically($1);
            $next->(@args);
        }
        else {
            die $_;
        }
    }
}

1;
