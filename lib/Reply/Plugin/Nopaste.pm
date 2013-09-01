package main;
use strict;
use warnings;
# ABSTRACT: command to nopaste a transcript of the current session

use mop;

use App::Nopaste;

=head1 SYNOPSIS

  ; .replyrc
  [Nopaste]
  service = Gist

=head1 DESCRIPTION

This plugin provides a C<#nopaste> command, which will use L<App::Nopaste> to
nopaste a transcript of the current Reply session. The C<service> option can be
used to choose an alternate service to use, rather than using the one that
App::Nopaste chooses on its own. If arguments are passed to the C<#nopaste>
command, they will be used as the title of the paste.

Note that this plugin should be loaded early in your configuration file, in
order to ensure that it sees all modifications to the result (due to plugins
like [DataDump], etc).

=cut

class Reply::Plugin::Nopaste extends Reply::Plugin {
    has $!history = '';
    has $!service;

    has $!prompt;
    has $!line;
    has $!result;

    method prompt ($next, @args) {
        $!prompt = $next->(@args);
        return $!prompt;
    }

    method read_line ($next, @args) {
        $!line = $next->(@args);
        $!line = "$!line\n" if defined $!line;
        return $!line;
    }

    method print_error ($next, $error) {
        $!result = $error;
        $next->($error);
    }

    method print_result ($next, @result) {
        $!result = @result ? join('', @result) . "\n" : '';
        $next->(@result);
    }

    method loop ($continue) {
        $!history .= "$!prompt$!line$!result"
            if defined $!prompt
            && defined $!line
            && defined $!result;

        undef $!prompt;
        undef $!line;
        undef $!result;

        $continue;
    }

    method command_nopaste ($cmd_line) {
        $cmd_line = "Reply session" unless length $cmd_line;

        print App::Nopaste->nopaste(
            text => $!history,
            desc => $cmd_line,
            lang => 'perl',
            (defined $!service
                ? (services => [ $!service ])
                : ()),
        ) . "\n";

        return '';
    }
}

=for Pod::Coverage
  command_nopaste

=cut

1;
