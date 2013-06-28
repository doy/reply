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

    my ($package, $func);
    if ($fragment =~ /:/) {
        ($package, $func) = ($fragment =~ /^(.+:)(\w*)$/);
        $func = '' unless defined $func;
        $package =~ s/:{1,2}$//;
    }
    else {
        $package = $self->{'package'};
        $func = $fragment;
    }

    return
        map  { $package eq $self->{'package'} ? $_ : "$package\::$_" }
        grep { $func ? /^\Q$func/ : 1 }
        'Package::Stash'->new($package)->list_all_symbols('CODE');
}

sub package {
    my $self = shift;
    my ($pkg) = @_;
    $self->{'package'} = $pkg;
}

1;
