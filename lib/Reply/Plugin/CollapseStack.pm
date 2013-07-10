package Reply::Plugin::CollapseStack;
use strict;
use warnings;
# ABSTRACT: display error stack traces only on demand

use base 'Reply::Plugin';

{
    local @SIG{qw(__DIE__ __WARN__)};
    require Carp::Always;
}

=head1 SYNOPSIS

  ; .replyrc
  [CollapseStack]
  num_lines = 1

=head1 DESCRIPTION

This plugin hides stack traces until you specifically request them
with the C<#stack> command.

The number of lines of stack to always show is configurable; specify
the C<num_lines> option.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{num_lines} = $opts{num_lines} || 1;

    return $self;
}

sub compile {
    my $self = shift;
    my ($next, @args) = @_;

    local $SIG{__DIE__} = \&Carp::Always::_die;
    $next->(@args);
}

sub execute {
    my $self = shift;
    my ($next, @args) = @_;

    local $SIG{__DIE__} = \&Carp::Always::_die;
    $next->(@args);
}

sub mangle_error {
    my $self = shift;
    my $error = shift;

    $self->{full_error} = $error;

    my @lines = split /\n/, $error;
    if (@lines > $self->{num_lines}) {
        splice @lines, $self->{num_lines};
        $error = join "\n", @lines, "    (Run #stack to see the full trace)\n";
    }

    return $error;
}

sub command_stack {
    my $self = shift;

    # XXX should use print_error here
    print($self->{full_error} || "No stack to display.\n");

    return '';
}

=for Pod::Coverage
  command_stack

=cut

1;

