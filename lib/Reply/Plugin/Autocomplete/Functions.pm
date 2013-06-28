package Reply::Plugin::Autocomplete::Functions;
use strict;
use warnings;
# ABSTRACT: tab completion for function names

use base 'Reply::Plugin';

use Module::Runtime '$module_name_rx';
use Package::Stash;

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Functions]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete function names in Perl
code, including imported functions.

=cut

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($before, $fragment) = $line =~ /(.*?)(${module_name_rx}(::)?)$/;
    return unless $fragment;

    my ($package, $func) = ($fragment =~ /^(.+:)(\w+)$/);
    $func = '' unless defined $func;
    $package = $self->{'package'} unless $package;
    $package =~ s/::$//;

    return
        map  { $package eq $self->{'package'} ? $_ : "$package\::$_" }
        grep { /^\Q$func/ }
        'Package::Stash'->new($package)->list_all_symbols('CODE');
}

sub package {
    my $self = shift;
    my ($pkg) = @_;
    $self->{'package'} = $pkg;
}

1;
