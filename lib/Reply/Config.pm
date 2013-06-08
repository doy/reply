package Reply::Config;
use strict;
use warnings;

use Config::INI::Reader::Ordered;
use File::HomeDir;
use File::Spec;

sub new {
    my $class = shift;
    my %opts = @_;

    $opts{file} = '.replyrc'
        unless defined $opts{file};

    my $file = File::Spec->catfile(
        (File::Spec->file_name_is_absolute($opts{file})
            ? ()
            : (File::HomeDir->my_home)),
        $opts{file}
    );

    my $self = bless {}, $class;

    $self->{file} = $file;
    $self->{config} = Config::INI::Reader::Ordered->new;

    return $self;
}

sub file { shift->{file} }

sub data {
    my $self = shift;

    return $self->{config}->read_file($self->{file});
}

1;
