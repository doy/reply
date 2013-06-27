package Reply::Plugin::Autocomplete::Lexicals;
use strict;
use warnings;
# ABSTRACT: tab completion for lexical variables

use base 'Reply::Plugin';

use PadWalker 'peek_sub';

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Lexicals]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete lexical variables in
Perl code.

=cut

# XXX unicode?
my $var_name_rx = qr/[\$\@\%]([A-Z_a-z][0-9A-Z_a-z]*)?/;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{env} = {};

    return $self;
}

sub compile {
    my $self = shift;
    my ($next, @args) = @_;

    my ($code) = $next->(@args);

    # XXX this is just copied from LexicalPersistence, which sucks first
    # because of copying and pasting code, and second because it doesn't catch
    # anything that wouldn't be caught by LexicalPersistence (setting lexicals
    # via Devel::StackTrace::WithLexicals (Carp::Reply), setting extra lexicals
    # (ResultCache))
    # we really need a way to broadcast various bits of information among
    # plugins
    $self->{env} = {
        %{ $self->{env} },
        %{ peek_sub($code) },
    };

    return $code;
}

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($var) = $line =~ /($var_name_rx)$/;
    return unless $var;

    my ($sigil, $name_prefix) = $var =~ /(.)(.*)/;

    my @results;
    for my $env_var (keys %{ $self->{env} }) {
        my ($env_sigil, $env_name) = $env_var =~ /(.)(.*)/;

        next unless index($env_name, $name_prefix) == 0;

        if ($sigil eq $env_sigil) {
            push @results, $env_name;
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

=for Pod::Coverage
  tab_handler

=cut

1;
