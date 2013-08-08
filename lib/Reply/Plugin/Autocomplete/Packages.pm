package main;
use strict;
use warnings;
# ABSTRACT: tab completion for package names

use mop;

use Module::Runtime '$module_name_rx';

use Reply::Util 'all_packages';

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Packages]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete package names in Perl
code.

=cut

class Reply::Plugin::Autocomplete::Packages extends Reply::Plugin {
    method tab_handler ($line) {

        # $module_name_rx does not permit trailing ::
        my ($before, $package_fragment) = $line =~ /(.*?)(${module_name_rx}:?:?)$/;
        return unless $package_fragment;
        return if $before =~ /^#/; # command
        return if $before =~ /->\s*$/; # method call
        return if $before =~ /[\$\@\%\&\*]\s*$/;

        return sort grep { index($_, $package_fragment) == 0 } all_packages();
    }
}

1;
