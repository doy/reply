package App::REPL;
use strict;
use warnings;

sub new {
    bless {}, shift;
}

sub run {
    my $self = shift;

    while (defined(my $line = $self->_read)) {
        my $result = $self->_eval($line);
        $self->_print($result);
    }
    print "\n";
}

sub _read {
    my $self = shift;

    print "> ";
    return <>;
}

sub _eval {
    my $self = shift;
    my ($line) = @_;

    return eval $line;
}

sub _print {
    my $self = shift;
    my ($result) = @_;

    print $result, "\n"
        if defined $result;
}

1;
