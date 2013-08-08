package main;

my $default_hints;
my $default_hinthash;
my $default_warning_bits;
BEGIN {
    $default_hints = $^H;
    $default_hinthash = { %^H };
    $default_warning_bits = ${^WARNING_BITS};
}

use strict;
use warnings;
# ABSTRACT: persists lexical hints across input lines

use mop;

=head1 SYNOPSIS

  ; .replyrc
  [Hints]

=head1 DESCRIPTION

This plugin persists the values of various compile time lexical hints between
evaluated lines. This means, for instance, that entering a line like C<use
strict> at the Reply prompt will cause C<strict> to be enabled for all future
lines (at least until C<no strict> is given).

=cut

class Reply::Plugin::Hints extends Reply::Plugin {
    has $hints        = $default_hints;
    has $hinthash     = $default_hinthash;
    has $warning_bits = $default_warning_bits;

    method mangle_line ($line) {
        my $package = __PACKAGE__;
        return <<LINE;
BEGIN {
    \$^H = \$${package}::HINTS;
    \%^H = \%\$${package}::HINTHASH;
    \${^WARNING_BITS} = \$${package}::WARNING_BITS;
}
$line
;
BEGIN {
    \$${package}::HINTS = \$^H;
    \$${package}::HINTHASH = \\\%^H;
    \$${package}::WARNING_BITS = \${^WARNING_BITS};
}
LINE
    }

    method compile ($next, $line, %args) {
        # XXX it'd be nice to avoid using globals here, but we can't use
        # eval_closure's environment parameter since we need to access the
        # information in a BEGIN block
        our $HINTS        = $hints;
        our $HINTHASH     = $hinthash;
        our $WARNING_BITS = $warning_bits;

        my @result = $next->($line, %args);

        $hints        = $HINTS;
        $hinthash     = $HINTHASH;
        $warning_bits = $WARNING_BITS;

        return @result;
    }
}

1;
