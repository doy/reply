package App::REPL::Plugin::Defaults;

# XXX Eval::Closure imposes its own hints on things that are eval'ed at the
# moment, but this may be fixed in the future
BEGIN {
    our $default_hints = $^H;
    our $default_hinthash = { %^H };
    our $default_warning_bits = ${^WARNING_BITS};
}

use strict;
use warnings;

use base 'App::REPL::Plugin';

use Eval::Closure;

sub display_prompt {
    my $self = shift;

    print "> ";
}

sub read_line {
    my $self = shift;

    return scalar <>;
}

my $PREFIX = "BEGIN { \$^H = \$" . __PACKAGE__ . "::default_hints; \%^H = \%\$" . __PACKAGE__ . "::default_hinthash; \${^WARNING_BITS} = \$" . __PACKAGE__ . "::default_warning_bits }";

sub evaluate {
    my $self = shift;
    my ($next, $line, %args) = @_;

    return eval_closure(
        source      => "sub { $PREFIX; $line }",
        terse_error => 1,
        %args,
    )->();
}

sub print_error {
    my $self = shift;
    my ($next, $error) = @_;

    print $error, "\n"
        if defined $error;
}

sub print_result {
    my $self = shift;
    my ($next, $result) = @_;

    print $result, "\n"
        if defined $result;
}

1;
