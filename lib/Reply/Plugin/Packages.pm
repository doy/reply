package Reply::Plugin::Packages;
use strict;
use warnings;

use base 'Reply::Plugin';

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{package} = 'main';

    return $self;
}

sub mangle_line {
    my $self = shift;
    my ($line) = @_;

    return "package $self->{package}; $line; BEGIN { \$" . __PACKAGE__ . "::package = __PACKAGE__ }";
}

sub compile {
    my $self = shift;
    my ($next, @args) = @_;

    # XXX it'd be nice to avoid using globals here, but we can't use
    # eval_closure's environment parameter since we need to access the
    # information in a BEGIN block
    our $package = $self->{package};

    my @result = $next->(@args);

    $self->{package} = $package;

    return @result;
}

1;
