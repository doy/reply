package main;
use strict;
use warnings;
# ABSTRACT: automatically refreshes the external code you use

use mop;

use Class::Refresh 0.05 ();

=head1 SYNOPSIS

  ; .replyrc
  [AutoRefresh]
  track_require = 1

=head1 DESCRIPTION

This plugin automatically refreshes all loaded modules before every
statement execution. It's useful if you are working on a module in
a file and you want the changes to automatically be loaded in Reply.

It takes a single argument, C<track_require>, which defaults to true.
If this option is set, the C<track_require> functionality from
L<Class::Refresh> will be enabled.

Note that to use the C<track_require> functionality, this module must
be loaded as early as possible (preferably first), so that other
modules correctly see the global override.

=cut

class Reply::Plugin::AutoRefresh extends Reply::Plugin {
    has $!track_require = 1;

    method BUILD {
        Class::Refresh->import(track_require => $!track_require);

        # so that when we load things after this plugin, they get a copy of
        # Module::Runtime which has the call to require() rebound to our
        # overridden copy. if this plugin is loaded first, these should be the
        # only modules loaded so far which load arbitrary user-specified
        # modules.
        Class::Refresh->refresh_module('Module::Runtime');
        Class::Refresh->refresh_module('base');
    }

    method compile ($next, @args) {
        Class::Refresh->refresh;
        $next->(@args);
    }
}

1;
