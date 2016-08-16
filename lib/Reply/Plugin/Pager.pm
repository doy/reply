package Reply::Plugin::Pager;
use strict;
use warnings;
# ABSTRACT: command to automatically open long results in a pager

use base 'Reply::Plugin';

use Term::ReadKey;

=head1 SYNOPSIS

  ; .replyrc
  [Pager]
  pager = less

=head1 DESCRIPTION

This plugin notices when too much output is going to be displayed as the result
of an expression, and automatically loads the result into a pager instead.

The C<pager> option can be specified to provide a different pager to use,
otherwise it will use the value of C<$ENV{PAGER}>.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    if (defined $opts{pager}) {
        $ENV{PAGER} = $opts{pager};
    }

    # delay this because it checks $ENV{PAGER} at load time
    require IO::Pager;

    my $self = $class->SUPER::new(@_);
    return $self;
}

sub print_result {
    my $self = shift;
    my ($next, @result) = @_;

    my ($cols, $rows) = GetTerminalSize;

    my @lines = map { split /\n/ } @result;
    if (@lines >= $rows - 2) {
        IO::Pager::open(my $fh) or die "Couldn't run pager: $!";
        $fh->print(@result, "\n");
    }
    else {
        $next->(@result);
    }
}

=for Pod::Coverage
  print_result

=cut

1;
