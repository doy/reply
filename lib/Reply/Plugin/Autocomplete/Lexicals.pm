package main;
use strict;
use warnings;
# ABSTRACT: tab completion for lexical variables

use mop;

use Reply::Util qw($varname_rx);

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Lexicals]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete lexical variables in
Perl code.

=cut

class Reply::Plugin::Autocomplete::Lexicals extends Reply::Plugin {
    method tab_handler ($line) {
        my ($var) = $line =~ /($varname_rx)$/;
        return unless $var;

        my ($sigil, $name_prefix) = $var =~ /(.)(.*)/;

        # these can't be lexicals
        return if $sigil eq '&' || $sigil eq '*';

        my $env = { map { %$_ } $self->publish('lexical_environment') };
        my @env = keys %$env;

        my @results;
        for my $env_var (@env) {
            my ($env_sigil, $env_name) = $env_var =~ /(.)(.*)/;

            next unless index($env_name, $name_prefix) == 0;

            # this is weird, not sure why % gets stripped but not $ or @
            if ($sigil eq $env_sigil) {
                push @results, $sigil eq '%' ? $env_var : $env_name;
            }
            elsif ($env_sigil eq '@' && $sigil eq '$') {
                push @results, "$env_name\[";
            }
            elsif ($env_sigil eq '%') {
                push @results, "$env_name\{";
            }
        }

        return @results;
    }
}

1;
