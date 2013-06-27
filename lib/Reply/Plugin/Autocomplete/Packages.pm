package Reply::Plugin::Autocomplete::Packages;
use strict;
use warnings;
# ABSTRACT: tab completion for package names

use base 'Reply::Plugin';

use Module::Runtime '$module_name_rx';

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Packages]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete package names in Perl
code.

=cut

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    # $module_name_rx does not permit trailing ::
    my ($before, $package_fragment) = $line =~ /(.*?)(${module_name_rx}:?:?)$/;
    return unless $package_fragment;
    return if $before =~ /[\$\@\%\&\*]\s*$/;

    my $file_fragment = $package_fragment;
    $file_fragment =~ s{::}{/}g;

    my $re = qr/^\Q$file_fragment/;

    my @results;
    for my $inc (keys %INC) {
        if ($inc =~ $re) {
            $inc =~ s{/}{::}g;
            $inc =~ s{\.pm$}{};
            push @results, $inc;
        }
    }

    return @results;
}

=for Pod::Coverage
  tab_handler

=cut

1;
