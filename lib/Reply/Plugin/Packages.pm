package main;
use strict;
use warnings;
# ABSTRACT: persist the current package between lines

use mop;

=head1 SYNOPSIS

  ; .replyrc
  [Packages]
  default_package = My::Scratchpad

=head1 DESCRIPTION

This plugin persists the state of the current package between lines. This
allows lines such as C<package Foo;> in the Reply shell to do what you'd
expect. The C<default_package> configuration option can also be used to set the
initial package to use when Reply starts up.

=cut

class Reply::Plugin::Packages extends Reply::Plugin {
    has $!package = 'main';

    submethod BUILD ($args) {
        $!package = $args->{default_package}
            if defined $args->{default_package};
    }

    method mangle_line ($line) {
        my $!package = __PACKAGE__;
        return <<LINE;
$line
;
BEGIN {
    \$${package}::PACKAGE = __PACKAGE__;
}
LINE
    }

    method compile ($next, $line, %args) {
        my @result = $next->($line, %args);

        # XXX it'd be nice to avoid using globals here, but we can't use
        # eval_closure's environment parameter since we need to access the
        # information in a BEGIN block
        $!package = our $PACKAGE;

        return @result;
    }

    method package { $!package }
}

1;
