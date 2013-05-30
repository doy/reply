package App::REPL::Plugin::Packages;
use strict;
use warnings;

use base 'App::REPL::Plugin';

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{package} = 'main';

    return $self;
}

sub evaluate {
    my $self = shift;
    my ($next, $line, %args) = @_;

    # XXX it'd be nice to avoid using globals here, but we can't use
    # eval_closure's environment parameter since we need to access the
    # information in a BEGIN block
    our $package = $self->{package};

    $line = "package $package; $line; BEGIN { \$" . __PACKAGE__ . "::package = __PACKAGE__ }";

    my @result = $next->($line, %args);

    $self->{package} = $package;

    return @result;
}

1;
