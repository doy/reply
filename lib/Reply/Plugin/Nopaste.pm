package Reply::Plugin::Nopaste;
use strict;
use warnings;

use base 'Reply::Plugin';

use App::Nopaste;

# XXX note that this has to be loaded early, in order to catch all of the
# appropriate manipulations that plugins do ([DataDump], etc)

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{history} = '';
    $self->{service} = $opts{service};

    return $self;
}

sub prompt {
    my $self = shift;
    my ($next, @args) = @_;
    my $prompt = $next->(@args);
    $self->{prompt} = $prompt;
    return $prompt;
}

sub read_line {
    my $self = shift;
    my ($next, @args) = @_;
    my $line = $next->(@args);
    $self->{line} = "$line\n" if defined $line;
    return $line;
}

sub print_error {
    my $self = shift;
    my ($next, $error) = @_;
    $self->{result} = $error;
    $next->($error);
}

sub print_result {
    my $self = shift;
    my ($next, @result) = @_;
    $self->{result} = @result ? join('', @result) . "\n" : '';
    $next->(@result);
}

sub loop {
    my $self = shift;

    my $prompt = delete $self->{prompt};
    my $line   = delete $self->{line};
    my $result = delete $self->{result};

    $self->{history} .= "$prompt$line$result";
}

sub command_nopaste {
    my $self = shift;
    my ($line) = @_;

    $line = "Reply session" unless length $line;

    App::Nopaste->nopaste(
        text => $self->{history},
        desc => $line,
        lang => 'perl',
        (defined $self->{service}
            ? (services => [ $self->{service} ])
            : ()),
    );

    return '';
}

1;
