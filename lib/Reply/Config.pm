package Reply::Config;
use strict;
use warnings;
# ABSTRACT: config loading for Reply

use Config::INI::Reader::Ordered;
use File::HomeDir;
use File::Spec;

=head1 SYNOPSIS

  use Reply;
  use Reply::Config;

  Reply->new(config => Reply::Config->new(file => 'something_else'))->run;

=head1 DESCRIPTION

This class abstracts out the config file loading, so that other applications
can start up Reply shells using similar logic. Reply configuration is specified
in an INI format - see L<Reply> for more details.

=cut

=method new(%opts)

Creates a new config object. Valid options are:

=over 4

=item file

Configuration file to use. If the file is specified by a relative path, it will
be relative to the user's home directory, otherwise it will be used as-is.

=back

=cut

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

=method file

Returns the absolute path to the config file that is to be used.

=cut

sub file { shift->{file} }

=method data

Returns the loaded configuration data.

=cut

sub data {
    my $self = shift;

    return $self->{config}->read_file($self->{file});
}

1;
