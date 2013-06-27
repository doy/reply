package Reply::Plugin::Packages;
use strict;
use warnings;
# ABSTRACT: persist the current package between lines

use base 'Reply::Plugin';

=head1 SYNOPSIS

  ; .replyrc
  [Packages]
  default_package = My::Scratchpad

=head1 DESCRIPTION

This plugin persists the state of the current package between lines. This
allows lines such as C<package Foo;> in the Reply shell to do what you'd
expect. The C<default_package> configuration option can also be used to set the
initial package to use when Reply starts up.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{package} = $opts{default_package} || 'main';

    $self->publish('package', $self->{package});

    return $self;
}

sub mangle_line {
    my $self = shift;
    my ($line) = @_;

    my $package = __PACKAGE__;
    return <<LINE;
$line
;
BEGIN {
    \$${package}::package = __PACKAGE__;
}
LINE
}

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    my @result = $next->($line, %args);

    # XXX it'd be nice to avoid using globals here, but we can't use
    # eval_closure's environment parameter since we need to access the
    # information in a BEGIN block
    $self->{package} = our $package;
    $self->publish('package', $self->{package});

    return @result;
}

1;
