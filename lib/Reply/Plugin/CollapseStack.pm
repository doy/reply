package main;
use strict;
use warnings;
# ABSTRACT: display error stack traces only on demand

use mop;

{
    local @SIG{qw(__DIE__ __WARN__)};
    require Carp::Always;
}

=head1 SYNOPSIS

  ; .replyrc
  [CollapseStack]
  num_lines = 1

=head1 DESCRIPTION

This plugin hides stack traces until you specifically request them
with the C<#stack> command.

The number of lines of stack to always show is configurable; specify
the C<num_lines> option.

=cut

class Reply::Plugin::CollapseStack extends Reply::Plugin {
    has $!num_lines = 1;

    has $!full_error;

    method compile ($next, @args) {
        local $SIG{__DIE__} = \&Carp::Always::_die;
        $next->(@args);
    }

    method execute ($next, @args) {
        local $SIG{__DIE__} = \&Carp::Always::_die;
        $next->(@args);
    }

    method mangle_error ($error) {
        $!full_error = $error;

        my @lines = split /\n/, $error;
        if (@lines > $!num_lines) {
            splice @lines, $!num_lines;
            $error = join "\n", @lines,
                                "    (Run #stack to see the full trace)\n";
        }

        return $error;
    }

    method command_stack {
        # XXX should use print_error here
        print($!full_error || "No stack to display.\n");
        return '';
    }
}

=for Pod::Coverage
  command_stack

=cut

1;

