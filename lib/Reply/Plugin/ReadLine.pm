package Reply::Plugin::ReadLine;
use strict;
use warnings;

use base 'Reply::Plugin';

use Term::ReadLine;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{term} = Term::ReadLine->new('Reply');

    return $self;
}

sub read_line {
    my $self = shift;
    my ($next, $prompt) = @_;

    return $self->{term}->readline($prompt);
}

1;
