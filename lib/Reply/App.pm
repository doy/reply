package Reply::App;
use strict;
use warnings;
# ABSTRACT: command line app runner for Reply

use Getopt::Long 'GetOptionsFromArray';

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

    my $cfgfile = '.replyrc';
    my $exitcode;
    my $parsed = GetOptionsFromArray(
        \@argv,
        'cfg:s'   => \$cfgfile,
        'version' => sub { $exitcode = 0; version() },
        'help'    => sub { $exitcode = 0; usage() },
    );

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
        if (open my $fh, '>', $file) {
            my $contents = do {
                local $/;
                <DATA>
            };
            $contents =~ s/use 5.XXX/use $]/;
            print $fh $contents;
            close $fh;
        }
        else {
            warn "Couldn't write to $file";
            %args = ();
        }
    }

    Reply->new(%args)->run;

    return 0;
}

=method usage

Prints usage information to the screen.

=cut

sub usage {
    print "    reply [--version] [--help] [--cfg file]\n";
}

=method version

Prints version information to the screen.

=cut

sub version {
    print "Reply version $Reply::VERSION\n";
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
