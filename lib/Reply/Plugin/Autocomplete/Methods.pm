package Reply::Plugin::Autocomplete::Methods;
use strict;
use warnings;
# ABSTRACT: tab completion for methods

use base 'Reply::Plugin';

use Package::Stash;
use Scalar::Util 'blessed';

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Methods]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete method names in Perl
code.

=cut

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{env} = {};
    $self->{package} = 'main';

    return $self;
}

sub lexical_environment {
    my $self = shift;
    my ($name, $env) = @_;

    $self->{env}{$name} = $env;
}

sub package {
    my $self = shift;
    my ($package) = @_;

    $self->{package} = $package;
}

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($invocant, $method) = $line =~ /((?:\$\s*)?[A-Z_a-z][0-9A-Z_a-z:]*)->([A-Z_a-z][0-9A-Z_a-z]*)?$/;
    return unless $invocant;

    $method = '' unless defined $method;

    my $package;
    if ($invocant =~ /^\$/) {
        my $env = {
            (map { %$_ } values %{ $self->{env} }),
            (%{ $self->{env}{defaults} || {} }),
        };
        my $var = $env->{$invocant};
        return unless $var && ref($var) eq 'REF' && blessed($$var);
        $package = blessed($$var);
    }
    else {
        $package = $invocant;
    }

    my $stash = eval { Package::Stash->new($package) };
    return unless $stash;

    my @results;
    for my $stash_method ($stash->list_all_symbols('CODE')) {
        next unless index($stash_method, $method) == 0;

        push @results, $stash_method;
    }

    return @results;
}

1;
