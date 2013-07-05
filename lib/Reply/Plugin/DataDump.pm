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

=head1 DESCRIPTION

This plugin uses L<Data::Dump> to format results. By default, if it reaches an
object which has a stringification overload, it will dump that directly. To
disable this behavior, set the C<respect_stringification> option to a false
value.

=cut

sub new {
    my $class = shift;
    my %opts = @_;
    $opts{respect_stringification} = 1
        unless defined $opts{respect_stringification};

    my $self = $class->SUPER::new(@_);
    $self->{filter} = sub {
        my ($ctx, $ref) = @_;
        return unless $ctx->is_blessed;
        my $stringify = overload::Method($ref, '""');
        return unless $stringify;
        return {
            dump => $stringify->($ref),
        };
    } if $opts{respect_stringification};

    return $self;
}

sub mangle_result {
    my $self = shift;
    my (@result) = @_;
    return @result ? dumpf(@result, $self->{filter}) : ();
}

1;
