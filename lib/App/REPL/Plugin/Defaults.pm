package App::REPL::Plugin::Defaults;

# don't pollute with strict and warnings for this module
sub _eval { eval($_[0]) }

use strict;
use warnings;

use base 'App::REPL::Plugin';

sub display_prompt {
    my $self = shift;

    print "> ";
}

sub read_line {
    my $self = shift;

    return scalar <>;
}

sub evaluate {
    my $self = shift;
    my ($next, $line) = @_;

    return _eval($line);
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
