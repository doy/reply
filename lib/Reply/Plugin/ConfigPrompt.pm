package Reply::Plugin::ConfigPrompt;
our $AUTHORITY = 'cpan:Balaji';
$Reply::Plugin::ConfigPrompt::VERSION = '0.01';
use strict;
use warnings;
# ABSTRACT: provides a configurable prompt

use base 'Reply::Plugin';


my %FORMAT_SUBS = (
	time => sub {
		my $s = shift;
		my $r = localtime;
		$s =~ s/\%T/$r/g;
		return $s;
	},
	counter => sub {
		my $s = shift;
		my $r = shift;
		$s =~ s/\%c/$r/g;
		return $s;
	},
	cwd => sub {
		use Cwd;
		use File::Basename;
		my $s = shift;
		my $r = fastgetcwd; my $rb = basename $r;
		$s =~ s/\%p/$r/g;
		$s =~ s/\%d/$rb/g;
		return $s;
	}
);


sub new {
    my $class = shift;
	my (%opt) = @_;
    my $self = $class->SUPER::new(@_);
    $self->{counter} = 0;
    $self->{prompted} = 0;
	$self->{format} = (exists $opt{format} and defined $opt{format}) ? $opt{format} : '%c >';
	if (exists $opt{color} and defined $opt{color}) {
		use Term::ANSIColor;
		if ($^O eq 'MSWin32') {
			require Win32::Console::ANSI;
			Win32::Console::ANSI->import;
		}
		$self->{prompt_color} = $opt{color};
	} else {
		$self->{prompt_color} = '';
	}
    return $self;
}

sub _expand_prompt_format {
	my $self = shift;
	my $_str = shift;
	my $caller = shift;
	foreach my $f (keys %FORMAT_SUBS) {
		$_str = $FORMAT_SUBS{$f}->($_str, $self->{counter}, $f);
	}
	if (defined $caller) {
		print $_str, "\n";
		return 1;
	} elsif ($self->{prompt_color}) {
		return colored [$self->{prompt_color}], $_str;
	} else {
		return $_str;
	}
}

sub prompt {
    my $self = shift;
    my ($next) = @_;
    $self->{prompted} = 1;
	return $self->_expand_prompt_format($self->{format} . ' ');
}

sub loop {
    my $self = shift;
    my ($continue) = @_;
    $self->{counter}++ if $self->{prompted};
    $self->{prompted} = 0;
    $continue;
}

sub command_test_prompt {
	my $self = shift;
	my $str = shift;
	return $self->_expand_prompt_format($str, caller);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Reply::Plugin::ConfigPrompt - provides a prompt that can be configured in the config file

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  ; .replyrc
  [ConfigPrompt]
  format = fixed_string %T %d %p %c >
  color  = bright_green

=head1 DESCRIPTION

This plugin enhances the default Reply prompt. It allows for the prompt to display
in a chosen color using the C<color> option. It also allows user to test
a prompt format before using it for his application.

=head2 Options

=head3 C<format>

Can contain one or more of the format specifiers C<%T> (current local time), C<%d>
(current working directory name), C<%p> (path to current working directory), and
C<%c> (a count of the number of lines executed so far). C<format> can also contain
string prefixes, brackets etc. For example the configuration

	; .replyrc
	[ConfigPrompt]
	format      = reply_shell %

produces the prompt

	reply_shell %

And this configuration

	; .replyrc
	[ConfigPrompt]
	format      = reply_shell [%T] >

produces the prompt

	reply_shell [Sat Oct 15 21:27:06 2016] >

You can test a given format by using the L<C<#test_prompt>|"C<#test_prompt>"> command.

=head3 C<color>

Can be any of the valid colors or attributes in Term::ANSIColor

=head2 Commands provided

=head3 #test_prompt

	> #test_prompt format_string
	format_string

This command can be used to test how a specific prompt would look before being added
to the reply configuration.

=head1 AUTHOR

Balaji Ramasubramanian E<lt>balaji.ramasubramanian@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2016 by Balaji Ramasubramanian.

This is free software, licensed under:

  The MIT (X11) License

=cut
