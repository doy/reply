package Reply::App;
use strict;
use warnings;
# ABSTRACT: command line app runner for Reply

use Getopt::Long 2.36 'GetOptionsFromArray';

use Reply;
use Reply::Config;

=head1 SYNOPSIS

  use Reply::App;
  exit(Reply::App->new->run(@ARGV));

=head1 DESCRIPTION

This module encapsulates the various bits of functionality related to running
L<Reply> as a command line application.

=cut

=method new

Returns a new Reply::App instance. Takes no arguments.

=cut

sub new { bless {}, shift }

=method run(@argv)

Parses the argument list given (typically from @ARGV), along with the user's configuration file, and attempts to start a Reply shell. A default configuration file will be generated for the user if none exists.

=cut

sub run {
    my $self = shift;
    my @argv = @_;

    Getopt::Long::Configure("gnu_getopt");

    my $cfgfile = '.replyrc';
    my $exitcode;
    my (@modules, @script_lines, @files);
    my $parsed = GetOptionsFromArray(
        \@argv,
        'cfg:s'   => \$cfgfile,
        'l|lib'   => sub { unshift @INC, 'lib' },
        'b|blib'  => sub { unshift @INC, 'blib/lib', 'blib/arch' },
        'I:s@'    => sub { unshift @INC, $_[1] },
        'M:s@'    => \@modules,
        'e:s@'    => \@script_lines,
        'version' => sub { $exitcode = 0; version() },
        'help'    => sub { $exitcode = 0; usage() },
    );

    @files = @argv;
    for my $file (@files) {
        if (!stat $file) {
            die "Can't read $file: $!";
        }
    }

    if (!$parsed) {
        usage(1);
        $exitcode = 1;
    }

    return $exitcode if defined $exitcode;

    my $cfg = Reply::Config->new(file => $cfgfile);

    my %args = (config => $cfg);
    my $file = $cfg->file;
    if (!-e $file) {
        print("$file not found. Generating a default...\n");
        unless ($self->generate_default_config($file)) {
            %args = ();
        }
    }

    my $reply = Reply->new(%args);
    $reply->step("use $_") for @modules;
    $reply->step($_, 1) for @script_lines;
    $reply->step('do "' . quotemeta($_) . '"', 1) for @files;
    $reply->run;

    return 0;
}

=method generate_default_config($file)

Generates default configuration file as per specified destination.

=cut

sub generate_default_config {
    my $self = shift;
    my ($file) = @_;

    if (open my $fh, '>', $file) {
        my $contents = do {
            local $/;
            <DATA>
        };
        $contents =~ s/use 5.XXX/use $]/;
        print $fh $contents;
        close $fh;

        return 1;
    }
    else {
        warn "Couldn't write to $file";

        return 0;
    }
}

=method usage($exitcode)

Prints usage information to the screen. If C<$exitcode> is 0, it will be
printed to C<STDOUT>, otherwise it will be printed to C<STDERR>.

=cut

sub usage {
    my $fh = $_[0] ? *STDERR : *STDOUT;
    print $fh "    reply [-lb] [-I dir] [-M mod] [--version] [--help] [--cfg file]\n";
}

=method version($exitcode)

Prints version information to the screen. If C<$exitcode> is 0, it will be
printed to C<STDOUT>, otherwise it will be printed to C<STDERR>.

=cut

sub version {
    my $fh = $_[0] ? *STDERR : *STDOUT;
    print $fh "Reply version $Reply::VERSION\n";
}

1;

__DATA__
script_line1 = use strict
script_line2 = use warnings
script_line3 = use 5.XXX

[Interrupt]
[FancyPrompt]
[DataDumper]
[Colors]
[ReadLine]
[Hints]
[Packages]
[LexicalPersistence]
[ResultCache]
[Autocomplete::Packages]
[Autocomplete::Lexicals]
[Autocomplete::Functions]
[Autocomplete::Globals]
[Autocomplete::Methods]
[Autocomplete::Commands]
