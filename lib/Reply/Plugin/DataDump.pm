package Reply::Plugin::DataDump;
use strict;
use warnings;
# ABSTRACT: format results using Data::Dump

use base 'Reply::Plugin';

use Data::Dump 'dumpf';
use overload ();

=head1 SYNOPSIS

  ; .replyrc
  [DataDump]
  respect_stringification = 1
  respect_freeze = 0

=head1 DESCRIPTION

This plugin uses L<Data::Dump> to format results. By default, if it reaches an
object which has a stringification overload, it will dump that directly. To
disable this behavior, set the C<respect_stringification> option to a false
value.
Also there is feature to reach C<freeze> method, to retrieve
suitable object instance for dumping.
Set C<respect_freeze> to enable this behaviour.

=cut

sub new {
    my $class = shift;
    my %opts = @_;
    $opts{respect_stringification} = 1
        unless defined $opts{respect_stringification};

    $opts{respect_freeze} = 0
        unless exists $opts{respect_freeze};

    my $self = $class->SUPER::new(@_);
    $self->{filter} = sub {
        my ($ctx, $ref) = @_;
        return unless $ctx->is_blessed;

        if ($opts{respect_stringification}) {
            my $stringify = overload::Method($ref, '""');

            return {
                dump => $stringify->($ref),
            } if $stringify;
        }

        if ($opts{respect_freeze} && $ref->can('freeze')) {
            return {
                object => $ref->freeze(),
            }
        }

        return;
    } if $opts{respect_stringification} || $opts{respect_freeze};

    return $self;
}

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return @result ? dumpf(@result, $self->{filter}) : ();
}

1;
