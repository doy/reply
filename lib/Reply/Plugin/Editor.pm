package Reply::Plugin::Editor;
use strict;
use warnings;

use base 'Reply::Plugin';

use File::HomeDir;
use File::Spec;
use Proc::InvokeEditor;

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{editor} = Proc::InvokeEditor->new(
        (defined $opts{editor}
            ? (editors => [ $opts{editor} ])
            : ())
    );
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

    return $text;
}

1;
