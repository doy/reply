package Reply::Plugin::ReadLine;
use strict;
use warnings;

use base 'Reply::Plugin';

use File::HomeDir;
use File::Spec;
use Term::ReadLine;

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

    if ($self->{term}->ReadLine eq 'Term::ReadLine::Gnu') {
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

    $self->{term}->WriteHistory($self->{history_file})
        or warn "Couldn't write history to $self->{history_file}";
}

1;
