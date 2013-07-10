package Reply::Util;
use strict;
use warnings;

BEGIN {
    if ($] < 5.010) {
        require MRO::Compat;
    }
    else {
        require mro;
    }
}

use Package::Stash;
use Scalar::Util 'blessed';

use Exporter 'import';
our @EXPORT_OK = qw(
    $ident_rx $varname_rx $fq_ident_rx $fq_varname_rx
    methods
);

# XXX this should be updated for unicode
our $varstart_rx   = qr/[A-Z_a-z]/;
our $varcont_rx    = qr/[0-9A-Z_a-z]/;
our $ident_rx      = qr/${varstart_rx}${varcont_rx}*/;
our $sigil_rx      = qr/[\$\@\%\&\*]/;
our $varname_rx    = qr/$sigil_rx\s*$ident_rx/;
our $fq_ident_rx   = qr/$ident_rx(?:::$varcont_rx+)*/;
our $fq_varname_rx = qr/$varname_rx(?:::$varcont_rx+)*/;

sub methods {
    my ($invocant) = @_;

    my $class = blessed($invocant) || $invocant;

    my @mro = (
        @{ mro::get_linear_isa('UNIVERSAL') },
        @{ mro::get_linear_isa($class) },
    );

    my @methods;
    for my $package (@mro) {
        my $stash = eval { Package::Stash->new($package) };
        next unless $stash;
        push @methods, $stash->list_all_symbols('CODE');
    }

    return @methods;
}

1;
