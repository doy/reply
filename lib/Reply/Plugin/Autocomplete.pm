package Reply::Plugin::Autocomplete;
use strict;
use warnings;
# ABSTRACT: tab complete your input

use base 'Reply::Plugin';

use B::Keywords qw/@Functions @Barewords/;
use Module::Runtime '$module_name_rx';

=head1 SYNOPSIS

  ; .replyrc
  [Autocomplete]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete Perl code.

=cut

sub tab_handler {
    my ($self, $line) = @_;

    return (
        $self->_tab_keyword($line),
        $self->_tab_package_loaded($line),
    );
}

sub _tab_keyword {
    my ($self, $line) = @_;

    my ($last_word) = $line =~ /(\w+)$/;
    return unless $last_word;

    my $re = qr/^\Q$last_word/;

    return grep { $_ =~ $re } @Functions, @Barewords;
}

sub _tab_package_loaded {
    my ($self, $line) = @_;

    # $module_name_rx does not permit trailing ::
    my ($package_fragment) = $line =~ /($module_name_rx(?:::)?)$/;
    return unless $package_fragment;

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

1;
