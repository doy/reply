package Reply::Plugin::ReadLine;
use strict;
use warnings;

use base 'Reply::Plugin';

use File::HomeDir;
use File::Spec;
use Term::ReadLine;

my $history = File::Spec->catfile(File::HomeDir->my_data, '.reply_history');

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{term} = Term::ReadLine->new('Reply');

    if (open my $fh, '<', $history) {
        for my $line (<$fh>) {
            chomp $line;
            $self->{term}->addhistory($line);
        }
    }
    else {
        my $e = $!;
        warn "Couldn't open $history for reading: $e"
            if -e $history;
    }

    return $self;
}

sub read_line {
    my $self = shift;
    my ($next, $prompt) = @_;

    return $self->{term}->readline($prompt);
}

sub DESTROY {
    my $self = shift;

    # XXX support more later
    return unless $self->{term}->ReadLine eq 'Term::ReadLine::Gnu';

    $self->{term}->WriteHistory($history)
        or warn "Couldn't write history to $history";
}

1;
