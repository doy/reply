package Reply::Plugin::AutoRefresh;
use strict;
use warnings;
# ABSTRACT: automatically refreshes the external code you use

use base 'Reply::Plugin';
use Class::Refresh 0.04;

=head1 SYNOPSIS

  ; .replyrc
  [AutoRefresh]

=head1 DESCRIPTION

This plugin automatically refreshes all loaded modules before every
statement execution. It's useful if you are working on a module in
a file and you want the changes to automatically be loaded in Reply.

=cut

sub compile {
    my $self = shift;
    my ($next, @args) = @_;

    Class::Refresh->refresh;
    $next->(@args);
}

1;
