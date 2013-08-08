package main;
use strict;
use warnings;
# ABSTRACT: use Term::ReadLine for user input

use mop;

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
persisted between runs, by default in C<.reply_history> in your application
data directory, although this is changeable with the C<history_file> option. To
limit the number of lines written to this file, you can use the
C<history_length> option. Setting a C<history_length> of C<0> will disable
writing history to a file entirely.

NOTE: you probably want to install a reasonable L<Term::ReadLine> backend in
order for this plugin to be very useful. L<Term::ReadLine::Gnu> is highly
recommended if possible.

=cut

class Reply::Plugin::ReadLine extends Reply::Plugin {
    has $term           = Term::ReadLine->new('Reply');
    has $history_file   = '.reply_history';
    has $history_length = -1;

    # XXX these should be able to be lazy, but defaults can't see attributes
    # yet it seems
    has $rl_gnu;
    has $rl_perl5;
    has $rl_caroline;

    submethod BUILD ($opts) {
        $rl_gnu      = $term->ReadLine eq 'Term::ReadLine::Gnu';
        $rl_perl5    = $term->ReadLine eq 'Term::ReadLine::Perl5';
        $rl_caroline = $term->ReadLine eq 'Term::ReadLine::Caroline';

        $history_file = File::Spec->catfile(
            (File::Spec->file_name_is_absolute($history_file)
                ? ()
                : (File::HomeDir->my_data)),
            $history_file
        );

        if ($rl_perl5) {
            # output compatible with Term::ReadLine::Gnu
            $readline::rl_scroll_nextline = 0;
        }

        if ($rl_perl5 || $rl_gnu || $rl_caroline) {
            $term->StifleHistory($history_length)
                if $history_length >= 0;
        }

        if (open my $fh, '<', $history_file) {
            for my $line (<$fh>) {
                chomp $line;
                $term->addhistory($line);
            }
        }
        else {
            my $e = $!;
            warn "Couldn't open $history_file for reading: $e"
                if -e $history_file;
        }

        $self->_register_tab_complete;
    }

    method read_line ($next, $prompt) {
        $term->readline($prompt);
    }

    submethod DEMOLISH {
        return if $history_length == 0;
        return unless $rl_gnu || $rl_perl5;
        $term->WriteHistory($history_file)
            or warn "Couldn't write history to $history_file";
    }

    method _register_tab_complete {
        weaken(my $weakself = $self);

        if ($rl_gnu) {
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

        if ($rl_perl5) {
            $term->Attribs->{completion_function} = sub {
                my ($text, $line, $start) = @_;
                my $end = $start + length($text);

                # discard everything after the cursor for completion purposes
                substr($line, $end) = '';

                my @matches = $weakself->publish('tab_handler', $line);
                return scalar(@matches) ? @matches : ();
            };
        }

        if ($rl_caroline) {
            $term->caroline->completion_callback(sub {
                my ($line) = @_;

                my @matches = $weakself->publish('tab_handler', $line);
                # for variable completion, method name completion.
                if (@matches && $line =~ /\W/) {
                    $line =~ s/[:\w]+\z//;
                    @matches = map { $line.$_ } @matches;
                }
                return scalar(@matches) ? @matches : ();
            });
        }
    }
}

1;
