package main;
use strict;
use warnings;
# ABSTRACT: attempts to load classes implicitly if possible

use mop;

use Module::Runtime 'use_package_optimistically';
use Try::Tiny;

=head1 SYNOPSIS

  ; .replyrc
  [LoadClass]

=head1 DESCRIPTION

If executing a line of code fails due to a method not being defined on a
package, this plugin will load the corresponding module and then try executing
the line again. This simplifies common cases like running C<< DateTime->now >>
at the prompt before loading L<DateTime> - this plugin will cause DateTime to
be loaded implicitly.

=cut

class Reply::Plugin::LoadClass extends Reply::Plugin {
    method execute ($next, @args) {
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
}

1;
