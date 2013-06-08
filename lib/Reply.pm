package Reply;
use strict;
use warnings;
# ABSTRACT: read, eval, print, loop, yay!

use Module::Runtime qw(compose_module_name use_package_optimistically);
use Scalar::Util qw(blessed);
use Try::Tiny;

use Reply::Config;

=head1 SYNOPSIS

  use Reply;

  Reply->new(config => "$ENV{HOME}/.replyrc")->run;

=head1 DESCRIPTION

NOTE: This is an early release, and implementation details of this module are
still very much in flux. Feedback is welcome!

Reply is a lightweight, extensible REPL for Perl. It is plugin-based (see
L<Reply::Plugin>), and through plugins supports many advanced features such as
coloring and pretty printing, readline support, and pluggable commands.

=head1 CONFIGURATION

Configuration uses an INI-style format similar to the configuration format of
L<Dist::Zilla>. Section names are used as the names of plugins, and any options
within a section are passed as arguments to that plugin. Plugins are loaded in
order as they are listed in the configuration file, which can affect the
results in some cases where multiple plugins are hooking into a single callback
(see L<Reply::Plugin> for more information).

In addition to plugin configuration, there are some additional options
recognized. These must be specified at the top of the file, before any section
headers.

=over 4

=item script_file

This contains a filename whose contents will be evaluated as perl code once the
configuration is done being loaded.

=item script_line<I<n>>

Any options that start with C<script_line> will be sorted by their key and then
each value will be evaluated individually once the configuration is done being
loaded.

NOTE: this is currently a hack due to the fact that L<Config::INI> doesn't
support multiple keys with the same name in a section. This may be fixed in the
future to just allow specifying C<script_line> multiple times.

=back

=cut

=method new(%opts)

Creates a new Reply instance. Valid options are:

=over 4

=item config

Name of a configuration file to load. This should contain INI-style
configuration for plugins as described above.

=item plugins

An arrayref of additional plugins to load.

=back

=cut

sub new {
    my $class = shift;
    my %opts = @_;

    require Reply::Plugin::Defaults;
    my $self = bless {
        plugins         => [],
        _default_plugin => Reply::Plugin::Defaults->new,
    }, $class;

    if (defined $opts{config}) {
        if (!ref($opts{config})) {
            $opts{config} = Reply::Config->new(file => $opts{config});
        }
        $self->_load_config($opts{config});
    }

    $self->_load_plugin($_) for @{ $opts{plugins} || [] };

    return $self;
}

=method run

Runs the repl. Will continue looping until the C<read_line> callback returns
undef or the C<loop> callback returns false.

=cut

sub run {
    my $self = shift;

    while (1) {
        my $continue = $self->step;
        last unless $continue;
    }
    print "\n";
}

=method step($line)

Runs a single iteration of the repl. If C<$line> is given, it will be used as
the string to evaluate (and the C<prompt> and C<read_line> callbacks will not
be called). Returns true if the repl can continue, and false if it was
requested to quit.

=cut

sub step {
    my $self = shift;
    my ($line) = @_;

    $line = $self->_read unless defined $line;

    return unless defined $line;

    $line = $self->_preprocess_line($line);

    try {
        my @result = $self->_eval($line);
        $self->_print_result(@result);
    }
    catch {
        $self->_print_error($_);
    };
    $self->_loop;
}

sub _load_config {
    my $self = shift;
    my ($config) = @_;

    my $data = $config->data;

    my $root_config;
    for my $section (@$data) {
        my ($name, $data) = @$section;
        if ($name eq '_') {
            $root_config = $data;
        }
        else {
            $self->_load_plugin($name => $data);
        }
    }

    for my $line (sort grep { /^script_line/ } keys %$root_config) {
        $self->step($root_config->{$line});
    }

    if (defined(my $file = $root_config->{script_file})) {
        my $contents = do {
            open my $fh, '<', $file or die "Couldn't open $file: $!";
            local $/ = undef;
            <$fh>
        };
        $self->step($contents);
    }
}

sub _load_plugin {
    my $self = shift;
    my ($plugin, $opts) = @_;

    if (!blessed($plugin)) {
        $plugin = compose_module_name("Reply::Plugin", $plugin);
        use_package_optimistically($plugin);
        die "$plugin is not a valid plugin"
            unless $plugin->isa("Reply::Plugin");
        $plugin = $plugin->new(%$opts);
    }

    push @{ $self->{plugins} }, $plugin;
}

sub _plugins {
    my $self = shift;

    return (
        @{ $self->{plugins} },
        $self->{_default_plugin},
    );
}

sub _read {
    my $self = shift;

    my $prompt = $self->_wrapped_plugin('prompt');
    return $self->_wrapped_plugin('read_line', $prompt);
}

sub _preprocess_line {
    my $self = shift;
    my ($line) = @_;

    if ($line =~ s/^#(\w+)(?:\s+|$)//) {
        ($line) = $self->_chained_plugin("command_\L$1", $line);
    }

    return "\n#line 1 \"reply input\"\n$line";
}

sub _eval {
    my $self = shift;
    my ($line) = @_;

    ($line) = $self->_chained_plugin('mangle_line', $line)
        if defined $line;

    my ($code) = $self->_wrapped_plugin('compile', $line);
    return $self->_wrapped_plugin('execute', $code);
}

sub _print_error {
    my $self = shift;
    my ($error) = @_;

    ($error) = $self->_chained_plugin('mangle_error', $error);
    $self->_wrapped_plugin('print_error', $error);
}

sub _print_result {
    my $self = shift;
    my (@result) = @_;

    @result = $self->_chained_plugin('mangle_result', @result);
    $self->_wrapped_plugin('print_result', @result);
}

sub _loop {
    my $self = shift;

    $self->_chained_plugin('loop', 1);
}

sub _wrapped_plugin {
    my $self = shift;
    my @plugins = ref($_[0]) ? @{ shift() } : $self->_plugins;
    my ($method, @args) = @_;

    @plugins = grep { $_->can($method) } @plugins;

    return @args unless @plugins;

    my $plugin = shift @plugins;
    my $next = sub { $self->_wrapped_plugin(\@plugins, $method, @_) };

    return $plugin->$method($next, @args);
}

sub _chained_plugin {
    my $self = shift;
    my @plugins = ref($_[0]) ? @{ shift() } : $self->_plugins;
    my ($method, @args) = @_;

    @plugins = grep { $_->can($method) } @plugins;

    for my $plugin (@plugins) {
        @args = $plugin->$method(@args);
    }

    return @args;
}

=head1 BUGS

No known bugs.

Please report any bugs through RT: email
C<bug-reply at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Reply>.

=head1 SEE ALSO

L<Devel::REPL>

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc Reply

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Reply>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Reply>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Reply>

=item * Search CPAN

L<http://search.cpan.org/dist/Reply>

=back

=cut

1;
