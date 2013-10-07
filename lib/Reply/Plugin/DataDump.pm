package main;
use strict;
use warnings;
# ABSTRACT: format results using Data::Dump

use mop;

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

class Reply::Plugin::DataDump extends Reply::Plugin {
    has $!respect_stringification = 1;
    has $!filter = sub {
        my ($ctx, $ref) = @_;
        return unless $ctx->is_blessed;
        my $stringify = overload::Method($ref, '""');
        return unless $stringify;
        return {
            dump => $stringify->($ref),
        };
    };

    method BUILD {
        undef $!filter unless $!respect_stringification;
    }

    method mangle_result (@result) {
        return @result ? dumpf(@result, $!filter) : ();
    }
}

1;
