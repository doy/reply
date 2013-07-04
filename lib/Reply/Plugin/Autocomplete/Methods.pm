package Reply::Plugin::Autocomplete::Methods;
use strict;
use warnings;
# ABSTRACT: tab completion for methods

use base 'Reply::Plugin';

use MRO::Compat;
use Package::Stash;
use Scalar::Util 'blessed';

use Reply::Util qw($ident_rx $fq_ident_rx $fq_varname_rx);

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

    my ($invocant, $method) = $line =~ /($fq_varname_rx|$fq_ident_rx)->($ident_rx)?$/;
    return unless $invocant;
    # XXX unicode
    return unless $invocant =~ /^[\$A-Z_a-z]/;

    $method = '' unless defined $method;

    my $class;
    if ($invocant =~ /^\$/) {
        my $env = {
            (map { %$_ } values %{ $self->{env} }),
            (%{ $self->{env}{defaults} || {} }),
        };
        my $var = $env->{$invocant};
        return unless $var && ref($var) eq 'REF' && blessed($$var);
        $class = blessed($$var);
    }
    else {
        $class = $invocant;
    }

    my @mro = (
        @{ mro::get_linear_isa('UNIVERSAL') },
        @{ mro::get_linear_isa($class) },
    );

    my @results;
    for my $package (@mro) {
        my $stash = eval { Package::Stash->new($package) };
        next unless $stash;

        for my $stash_method ($stash->list_all_symbols('CODE')) {
            next unless index($stash_method, $method) == 0;

            push @results, $stash_method;
        }
    }

    return sort @results;
}

1;
