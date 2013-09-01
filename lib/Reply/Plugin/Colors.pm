package main;
use strict;
use warnings;
# ABSTRACT: colorize output

use mop;

use Term::ANSIColor;
BEGIN {
    if ($^O eq 'MSWin32') {
        require Win32::Console::ANSI;
        Win32::Console::ANSI->import;
    }
}

=head1 SYNOPSIS

  ; .replyrc
  [Colors]
  error_color   = bright red
  warning_color = bright yellow
  result_color  = bright green

=head1 DESCRIPTION

This plugin adds coloring to the results when they are printed to the screen.
By default, errors are C<red>, warnings are C<yellow>, and normal results are
C<green>, although this can be overridden through configuration as shown in the
synopsis. L<Term::ANSIColor> is used to generate the colors, so any value that
is accepted by that module is a valid value for the C<error>, C<warning>, and
C<result> options.

=cut

class Reply::Plugin::Colors extends Reply::Plugin {
    has $!error_color   = 'red';
    has $!warning_color = 'yellow';
    has $!result_color  = 'green';

    method compile ($next, @args) {
        local $SIG{__WARN__} = sub { $self->print_warn(@_) };
        $next->(@args);
    }

    method execute ($next, @args) {
        local $SIG{__WARN__} = sub { $self->print_warn(@_) };
        $next->(@args);
    }

    method print_error ($next, $error) {
        print color($!error_color);
        $next->($error);
        local $| = 1;
        print color('reset');
    }

    method print_result ($next, @result) {
        print color($!result_color);
        $next->(@result);
        local $| = 1;
        print color('reset');
    }

    method print_warn ($warning) {
        print color($!warning_color);
        print $warning;
        local $| = 1;
        print color('reset');
    }
}

=for Pod::Coverage
  print_warn

=cut

1;
