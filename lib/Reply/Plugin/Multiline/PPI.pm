package Reply::Plugin::Multiline::PPI;
use strict;
use warnings;
# ABSTRACT: command to edit the current line in a text editor

use base 'Reply::Plugin';
use PPI;

=head1 SYNOPSIS

  ; .replyrc
  [Multiple::PPI]

=head1 DESCRIPTION

This plugin provides multiline input support for the repl. In fact it is a
direct port of L<Devel::REPL::Plugin::MultiLine::PPI> plugin for L<Devel::REPL>.

Citing the original:

For example, without a MultiLine plugin,

    $ my $x = 3;
    3
    $ if ($x == 3) {

will throw a compile error, because that C<if> statement is incomplete. With a
MultiLine plugin,

    $ my $x = 3;
    3
    $ if ($x == 3) {

    > print "OH NOES!"

    > }
    OH NOES
    1

you may write the code across multiple lines, such as in C<irb> and C<python>.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{needs_continuation} = 0;

    return $self;
}

sub prompt {
    my $self = shift;
    my ($next, $read_coderef) = @_;

    return $self->{needs_continuation} ? '... ' : $next->();
}

sub read {
    my $self = shift;
    my ($next, $read_coderef) = @_;

    my $line = $read_coderef->();

    return unless defined $line;

    return $self->continue_reading_if_necessary($line, $read_coderef);
}

sub continue_reading_if_necessary {
    my ( $self, $line, $read_coderef ) = @_;

    while ($self->line_needs_continuation($line)) {
        $self->{needs_continuation} = 1;

        my $append = $read_coderef->();

        $line .= "\n$append" if defined($append);

        $self->{needs_continuation} = 0;

        # ^D means "shut up and eval already"
        return $line if !defined($append);
    }

    return $line;
}

sub line_needs_continuation
{
    my $repl = shift;
    my $line = shift;

    # add this so we can test whether the document ends in PPI::Statement::Null
    $line .= "\n;;";

    my $document = PPI::Document->new(\$line);
    return 0 if !defined($document);

    # adding ";" to a complete document adds a PPI::Statement::Null. we added a ;;
    # so if it doesn't end in null then there's probably something that's
    # incomplete
    return 0 if $document->child(-1)->isa('PPI::Statement::Null');

    # this could use more logic, such as returning 1 on s/foo/ba<Enter>
    my $unfinished_structure = sub
    {
        my ($document, $element) = @_;
        return 0 unless $element->isa('PPI::Structure');
        return 1 unless $element->finish;
        return 0;
    };

    return $document->find_any($unfinished_structure);
}

1;
