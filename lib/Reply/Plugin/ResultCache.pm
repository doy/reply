package main;
use strict;
use warnings;
# ABSTRACT: retain previous results to be able to refer to them later

use mop;

=head1 SYNOPSIS

  ; .replyrc
  [ResultCache]
  variable = r

=head1 DESCRIPTION

This plugin caches the results of successful evaluations, and provides them in
a lexical array (by default C<@res>, although this can be changed via the
C<variable> option). This means that you can, for instance, access the value
returned by the previous line with C<$res[-1]>. It also modifies the output to
include an indication of where the value is stored, for later reference.

=cut

class Reply::Plugin::ResultCache extends Reply::Plugin {
    has $results = [];
    has $variable = 'res';

    method execute ($next, @args) {
        my @res = $next->(@args);
        if (@res == 1) {
            push @$results, $res[0];
        }
        elsif (@res > 1) {
            push @$results, \@res;
        }

        return @res;
    }

    method mangle_result ($result) {
        return unless defined $result;
        return '$' . $variable . '[' . $#$results . '] = ' . $result;
    }

    method lexical_environment {
        return { "\@$variable" => [ @$results ] };
    }
}

1;
