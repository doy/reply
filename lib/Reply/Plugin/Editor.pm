package Reply::Plugin::Editor;
use strict;
use warnings;
# ABSTRACT: command to edit the current line in a text editor

use base 'Reply::Plugin';

use File::HomeDir;
use File::Spec;
use Proc::InvokeEditor;

=head1 SYNOPSIS

  ; .replyrc
  [Editor]
  editor = emacs

=head1 DESCRIPTION

This plugin provides the C<#e> command. It will launch your editor, and allow
you to edit bits of code in your editor, which will then be evaluated all at
once. The text you entered will be saved, and restored the next time you enter
the command. Alternatively, you can pass a filename to the C<#e> command, and
the contents of that file will be preloaded instead.

The C<editor> option can be specified to provide a different editor to use,
otherwise it will use the value of C<$ENV{VISUAL}> or C<$ENV{EDITOR}>.

The C<echo> option can be used to suppress or enable the display in reply
itself of the text inserted through the editor.

=head1 BUGS

Despite the C<echo> option being enabled, output will not be available through
the C<Nopaste> plugin.

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{editor} = Proc::InvokeEditor->new(
        (defined $opts{editor}
            ? (editors => [ $opts{editor} ])
            : ())
    );
    $self->{echo} = $opts{echo};
    $self->{current_text} = '';

    return $self;
}

sub command_e {
    my $self = shift;
    my ($line) = @_;

    my $text;
    if (length $line) {
        if ($line =~ s+^~/++) {
            $line = File::Spec->catfile(File::HomeDir->my_home, $line);
        }
        elsif ($line =~ s+^~([^/]*)/++) {
            $line = File::Spec->catfile(File::HomeDir->users_home($1), $line);
        }

        my $current_text = do {
            local $/;
            if (open my $fh, '<', $line) {
                <$fh>;
            }
            else {
                warn "Couldn't open $line: $!";
                return '';
            }
        };
        $text = $self->{editor}->edit($current_text, '.pl');
    }
    else {
        $text = $self->{editor}->edit($self->{current_text}, '.pl');
        $self->{current_text} = $text;
    }

    if($self->{echo}) {
      say $text;
    }
    
    return $text;
}

=for Pod::Coverage
  command_e

=cut

1;
