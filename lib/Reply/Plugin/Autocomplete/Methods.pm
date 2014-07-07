package Reply::Plugin::Autocomplete::Methods;
use strict;
use warnings;
# ABSTRACT: tab completion for methods

use base 'Reply::Plugin';

use Scalar::Util 'blessed';

use Reply::Util qw($ident_rx $fq_ident_rx $fq_varname_rx methods);

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  [Autocomplete::Methods]

=head1 DESCRIPTION

This plugin registers a tab key handler to autocomplete method names in Perl
code.

=cut

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    my ($invocant, $method_prefix) = $line =~ /($fq_varname_rx|$fq_ident_rx)->($ident_rx)?$/;
    return unless $invocant;
    # XXX unicode
    return unless $invocant =~ /^[\$A-Z_a-z]/;

    $method_prefix = '' unless defined $method_prefix;

    my $class;
    if ($invocant =~ /^\$/) {
        # XXX should support globals here
        my $env = {
            map { %$_ } $self->publish('lexical_environment'),
        };
        my $var = $env->{$invocant};
        return unless $var && ref($var) eq 'REF' && blessed($$var);
        $class = blessed($$var);
    }
    else {
        $class = $invocant;
    }

    my @results;
    for my $method (methods($class)) {
        push @results, $method if index($method, $method_prefix) == 0;
    }

    return sort @results;
}

1;
