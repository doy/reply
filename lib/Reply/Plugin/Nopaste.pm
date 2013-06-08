package Reply::Plugin::Nopaste;
use strict;
use warnings;
# ABSTRACT: command to nopaste a transcript of the current session

use base 'Reply::Plugin';

use App::Nopaste;

=head1 SYNOPSIS

  ; .replyrc
  [Nopaste]
  service = Gist

=head1 DESCRIPTION

This plugin provides a C<#nopaste> command, which will use L<App::Nopaste> to
nopaste a transcript of the current Reply session. The C<service> option can be
used to choose an alternate service to use, rather than using the one that
App::Nopaste chooses on its own. If arguments are passed to the C<#nopaste>
command, they will be used as the title of the paste.

Note that this plugin should be loaded early in your configuration file, in
order to ensure that it sees all modifications to the result (due to plugins
like [DataDump], etc).

=cut

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
    my ($continue) = @_;

    my $prompt = delete $self->{prompt};
    my $line   = delete $self->{line};
    my $result = delete $self->{result};

    $self->{history} .= "$prompt$line$result";

    $continue;
}

sub command_nopaste {
    my $self = shift;
    my ($line) = @_;

    $line = "Reply session" unless length $line;

    print App::Nopaste->nopaste(
        text => $self->{history},
        desc => $line,
        lang => 'perl',
        (defined $self->{service}
            ? (services => [ $self->{service} ])
            : ()),
    ) . "\n";

    return '';
}

=for Pod::Coverage
  command_nopaste

=cut

1;
