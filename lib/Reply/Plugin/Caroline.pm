package Reply::Plugin::Caroline;
use strict;
use warnings;
use utf8;

# ABSTRACT: use Caroline for user input

use base 'Reply::Plugin';

use File::HomeDir;
use File::Spec;
use Scalar::Util 'weaken';
use Caroline;

=head1 SYNOPSIS

  ; .replyrc
  [caroline]
  history_file = '.hist'
  history_length = 100

=head1 DESCRIPTION

This plugin uses L<Caroline> to read lines from the user. This enables
useful features such as line editing and command history. The history will be
persisted between runs, by default in C<.reply_history> in your application
data directory, although this is changeable with the C<history_file> option. To
limit the number of lines written to this file, you can use the
C<history_length> option. Setting a C<history_length> of C<0> will disable
writing history to a file entirely.

=cut


1;



sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{caroline} = Caroline->new();
    my $history = $opts{history_file} || '.reply_history';
    $self->{history_file} = File::Spec->catfile(
        (File::Spec->file_name_is_absolute($history)
            ? ()
            : (File::HomeDir->my_data)),
        $history
    );

    if (open my $fh, '<', $self->{history_file}) {
        for my $line (<$fh>) {
            chomp $line;
            $self->{caroline}->history_add($line);
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

    my $line = $self->{caroline}->readline($prompt);
    if (defined($line) && $line =~ /\S/) {
        $self->{caroline}->history_add($line);
    }
    return $line;
}

sub DESTROY {
    my $self = shift;

    return if defined $self->{history_length} && $self->{history_length} == 0;

    open my $fh, '>:utf8', $self->{history_file}
        or do {
        warn "Couldn't open $self->{history_file} for writing history: $!";
        return;
    };
    for my $history (@{$self->{caroline}->history}) {
        next unless $history =~ /\S/;
        print $fh "$history\n";
    }
}

sub _register_tab_complete {
    my $self = shift;

    my $caroline = $self->{caroline};

    weaken(my $weakself = $self);

    $caroline->completion_callback(sub {
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

1;
