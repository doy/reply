package Reply::Plugin::Defaults;

# XXX Eval::Closure imposes its own hints on things that are eval'ed at the
# moment, but this may be fixed in the future
BEGIN {
    our $default_hints = $^H;
    our $default_hinthash = { %^H };
    our $default_warning_bits = ${^WARNING_BITS};
}

use strict;
use warnings;

use base 'Reply::Plugin';

use Eval::Closure 0.11;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{quit} = 0;

    return $self;
}

sub prompt { "> " }

sub read_line {
    my $self = shift;
    my ($next, $prompt) = @_;

    print $prompt;
    return scalar <STDIN>;
}

(my $PREFIX = <<'PREFIX') =~ s/__PACKAGE__/__PACKAGE__/ge;
BEGIN {
    $^H = $__PACKAGE__::default_hints;
    %^H = %$__PACKAGE__::default_hinthash;
    ${^WARNING_BITS} = $__PACKAGE__::default_warning_bits;
}
PREFIX

sub read {
    my $self = shift;
    my ($next, $read_coderef) = @_;

    return $read_coderef->();
}

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    my $env     = { map { %$_ } $self->publish('lexical_environment') };
    my $package = ($self->publish('package'))[-1];
    $package = 'main' unless defined $package;

    my $prefix = "package $package;\n$PREFIX";

    my $code = eval_closure(
        source      => "sub {\n$prefix;\n$line\n}",
        terse_error => 1,
        alias       => 1,
        environment => $env,
        %args,
    );

    return $code;
}

sub execute {
    my $self = shift;
    my ($next, $code, @args) = @_;

    return $code->(@args);
}

sub print_error {
    my $self = shift;
    my ($next, $error) = @_;

    print $error
        if defined $error;
}

sub print_result {
    my $self = shift;
    my ($next, @result) = @_;

    print @result, "\n"
        if @result;
}

sub command_q {
    my $self = shift;
    $self->{quit} = 1;
    return '';
}

sub command_vars {
    my $self = shift;

    my %env = map { %$_ } $self->publish('lexical_environment');
    return '(' . join(', ', map { qq<'$_'> } keys %env) . ')';
}

sub loop {
    my $self = shift;
    my ($continue) = @_;

    $continue = 0 if $self->{quit};

    return $continue;
}

=begin Pod::Coverage

  new
  command_q
  command_vars
  read

=end Pod::Coverage

=cut

1;
