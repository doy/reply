package main;
use strict;
use warnings;
# ABSTRACT: config loading for Reply

use mop;

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

class Reply::Config {
    has $!file   = $_->_canonicalize_file('.replyrc');
    has $!config = Config::INI::Reader::Ordered->new;

    submethod BUILD ($args) {
        if (defined $args->{file}) {
            $!file = $self->_canonicalize_file($args->{file});
        }
    }

=method file

Returns the absolute path to the config file that is to be used.

=cut

    method file { $!file }

=method data

Returns the loaded configuration data.

=cut

    method data { $!config->read_file($!file) }

    method _canonicalize_file ($filename) {
        return File::Spec->catfile(
            (File::Spec->file_name_is_absolute($filename)
                ? ()
                : (File::HomeDir->my_home)),
            $filename
        );
    }
}

1;
