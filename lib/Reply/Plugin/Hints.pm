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

use base 'Reply::Plugin';

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

    return "BEGIN { \$^H = \$" . __PACKAGE__ . "::hints; \%^H = \%\$" . __PACKAGE__ . "::hinthash; \${^WARNING_BITS} = \$" . __PACKAGE__ . "::warning_bits } $line; BEGIN { \$" . __PACKAGE__ . "::hints = \$^H; \$" . __PACKAGE__ . "::hinthash = \\\%^H; \$" . __PACKAGE__ . "::warning_bits = \${^WARNING_BITS} }";
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
