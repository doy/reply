package Reply::Plugin::ResultCache;
use strict;
use warnings;
# ABSTRACT: retain previous results to be able to refer to them later

use base 'Reply::Plugin';

=head1 SYNOPSIS

  ; .replyrc
  [ResultCache]
  variable = r

=head1 DESCRIPTION

This plugin caches the results of successful evaluations, and provides them in
a lexical array (by default C<@res>, although this can be changed via the
C<variable> option). This means that you can, for instance, access the value
returned by the previous line with C<$res[-1]>. It also modifies the output to
include an indication of where the value is stored, for later reference.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{results} = [];
    $self->{result_name} = $opts{variable} || 'res';

    return $self;
}

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    $args{environments}{''.__PACKAGE__} = {
        "\@$self->{result_name}" => $self->{results},
    };

    $next->($line, %args);
}

sub execute {
    my $self = shift;
    my ($next, @args) = @_;

    my @res = $next->(@args);
    if (@res == 1) {
        push @{ $self->{results} }, $res[0];
    }
    elsif (@res > 1) {
        push @{ $self->{results} }, \@res;
    }

    return @res;
}

sub mangle_result {
    my $self = shift;
    my ($result) = @_;

    return unless defined $result;
    return '$' . $self->{result_name} . '[' . $#{ $self->{results} } . '] = '
         . $result;
}

1;
