package Reply::Plugin::ReadLine;
use strict;
use warnings;
# ABSTRACT: use Term::ReadLine for user input

use base 'Reply::Plugin';

use File::HomeDir;
use File::Spec;
use Scalar::Util 'weaken';
use Term::ReadLine;

=head1 SYNOPSIS

  ; .replyrc
  [ReadLine]
  history_file = '.hist'
  history_length = 100

=head1 DESCRIPTION

This plugin uses L<Term::ReadLine> to read lines from the user. This enables
useful features such as line editing and command history. The history will be
persisted between runs, by default in C<~/.reply_history>, although this is
changeable with the C<history_file> option. To limit the number of lines
written to this file, you can use the C<history_length> option. Setting a
C<history_length> of C<0> will disable writing history to a file entirely.

NOTE: you probably want to install a reasonable L<Term::ReadLine> backend in
order for this plugin to be very useful. L<Term::ReadLine::Gnu> is highly
recommended if possible.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{term} = Term::ReadLine->new('Reply');
    my $history = $opts{history_file} || '.reply_history';
    $self->{history_file} = File::Spec->catfile(
        (File::Spec->file_name_is_absolute($history)
            ? ()
            : (File::HomeDir->my_data)),
        $history
    );

    $self->{rl_gnu} = $self->{term}->ReadLine eq 'Term::ReadLine::Gnu';
    $self->{rl_perl5} = $self->{term}->ReadLine eq 'Term::ReadLine::Perl5';

    if ($self->{rl_perl5}) {
        # output compatible with Term::ReadLine::Gnu
        $readline::rl_scroll_nextline = 0;
    }

    if ($self->{rl_perl5} || $self->{rl_gnu}) {
        $self->{term}->StifleHistory($opts{history_length})
            if defined $opts{history_length} && $opts{history_length} >= 0;
    }

    if (open my $fh, '<', $self->{history_file}) {
        for my $line (<$fh>) {
            chomp $line;
            $self->{term}->addhistory($line);
        }
    }
    else {
        my $e = $!;
        warn "Couldn't open $self->{history_file} for reading: $e"
            if -e $self->{history_file};
    }

    $self->_register_tab_complete;

    return $self;
}

sub read_line {
    my $self = shift;
    my ($next, $prompt) = @_;

    return $self->{term}->readline($prompt);
}

sub DESTROY {
    my $self = shift;

    return if defined $self->{history_length} && $self->{history_length} == 0;

    # XXX support more later
    return unless ($self->{rl_gnu} || $self->{rl_perl5});

    $self->{term}->WriteHistory($self->{history_file})
        or warn "Couldn't write history to $self->{history_file}";
}

sub _register_tab_complete {
    my $self = shift;

    my $term = $self->{term};

    weaken(my $weakself = $self);

    if ($self->{rl_gnu}) {
        $term->Attribs->{attempted_completion_function} = sub {
            my ($text, $line, $start, $end) = @_;

            # discard everything after the cursor for completion purposes
            substr($line, $end) = '';

            my @matches = $weakself->publish('tab_handler', $line);
            my $match_index = 0;

            return $term->completion_matches($text, sub {
                my ($text, $index) = @_;
                return $matches[$index];
            });
        };
    }

    if ($self->{rl_perl5}) {
        $term->Attribs->{completion_function} = sub {
            my ($text, $line, $start) = @_;
            my $end = $start + length($text);

            # discard everything after the cursor for completion purposes
            substr($line, $end) = '';

            my @matches = $weakself->publish('tab_handler', $line);
            return scalar(@matches) ? @matches : ();
        };
    }
}

1;
