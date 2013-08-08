package main;
use strict;
use warnings;
# ABSTRACT: time commands

use mop;

use Time::HiRes qw(gettimeofday tv_interval);

=head1 SYNOPSIS

  ; .replyrc
  [Timer]
  mintime = 0.01

=head1 DESCRIPTION

This plugin prints timer info for results that take longer than C<mintime>.
the default C<mintime> is C<< 0.01 >> seconds.

=cut

class Reply::Plugin::Timer extends Reply::Plugin {
    has $mintime = 0.01;

    method execute ($next, @args) {
        my $t0 = [gettimeofday];
        my $ret = $next->(@args);
        my $elapsed = tv_interval($t0);

        if ($elapsed > $mintime) {
            if ($elapsed >= 1) {
                printf "Execution Time: %0.3fs\n", $elapsed
            } else {
                printf "Execution Time: %dms\n", $elapsed * 1000
            }
        }

        return $ret;
    }
}

1;
