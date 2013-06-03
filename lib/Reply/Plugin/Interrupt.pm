package Reply::Plugin::Interrupt;
use strict;
use warnings;
# ABSTRACT: allows using Ctrl+C to interrupt long-running lines

use base 'Reply::Plugin';

=head1 SYNOPSIS

  ; .replyrc
  [Interrupt]

=head1 DESCRIPTION

This plugin allows you to use Ctrl+C to interrupt long running commands without
exiting the Reply shell entirely.

=cut

sub compile {
    my $self = shift;
    my ($next, @args) = @_;

    local $SIG{INT} = sub { die "Interrupted" };
    $next->(@args);
}

sub execute {
    my $self = shift;
    my ($next, @args) = @_;

    local $SIG{INT} = sub { die "Interrupted" };
    $next->(@args);
}

1;
