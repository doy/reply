package Reply::Plugin::Hints;

my $default_hints;
my $default_hinthash;
my $default_warning_bits;
BEGIN {
    $default_hints = $^H;
    $default_hinthash = \%^H;
    $default_warning_bits = ${^WARNING_BITS};
}

use strict;
use warnings;
# ABSTRACT: persists lexical hints across input lines

use base 'Reply::Plugin';

=head1 SYNOPSIS

  ; .replyrc
  [Hints]

=head1 DESCRIPTION

This plugin persists the values of various compile time lexical hints between
evaluated lines. This means, for instance, that entering a line like C<use
strict> at the Reply prompt will cause C<strict> to be enabled for all future
lines (at least until C<no strict> is given).

=cut

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{hints} = $default_hints;
    $self->{hinthash} = $default_hinthash;
    $self->{warning_bits} = $default_warning_bits;

    return $self;
}

sub mangle_line {
    my $self = shift;
    my ($line) = @_;

    my $package = __PACKAGE__;
    return <<LINE;
BEGIN {
    \$^H = \$${package}::hints;
    \%^H = \%\$${package}::hinthash;
    \${^WARNING_BITS} = \$${package}::warning_bits;
}
$line
;
BEGIN {
    \$${package}::hints = \$^H;
    \$${package}::hinthash = \\\%^H;
    \$${package}::warning_bits = \${^WARNING_BITS};
}
LINE
}

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    # XXX it'd be nice to avoid using globals here, but we can't use
    # eval_closure's environment parameter since we need to access the
    # information in a BEGIN block
    our $hints = $self->{hints};
    our $hinthash = $self->{hinthash};
    our $warning_bits = $self->{warning_bits};

    my @result = $next->($line, %args);

    $self->{hints} = $hints;
    $self->{hinthash} = $hinthash;
    $self->{warning_bits} = $warning_bits;

    return @result;
}

1;
