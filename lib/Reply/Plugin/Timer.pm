package Reply::Plugin::Timer;
use strict;
use warnings;
# ABSTRACT: time commands

use base 'Reply::Plugin';

use Time::HiRes qw(gettimeofday tv_interval);

=head1 SYNOPSIS

  ; .replyrc
  [Timer]
  mintime = 0.01

=head1 DESCRIPTION

This plugin prints timer info for results that take longer than C<mintime>.
the default C<mintime> is C<< 0.01 >> seconds.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{mintime} = $opts{mintime} || 0.01;

    return $self;
}


sub execute {
    my ($self, $next, @args) = @_;

    my $t0 = [gettimeofday];
    my $ret = $next->(@args);
    my $elapsed = tv_interval($t0);

    if ($elapsed > $self->{mintime}) {
        if ($elapsed >= 1) {
            printf "Execution Time: %0.3fs\n", $elapsed
        } else {
            printf "Execution Time: %dms\n", $elapsed * 1000
        }
    }

    return $ret;
}

1;
