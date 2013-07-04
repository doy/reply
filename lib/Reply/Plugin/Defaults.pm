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

use Eval::Closure;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{quit} = 0;
    $self->{env} = [];
    $self->{package} = 'main';

    return $self;
}

sub prompt { "> " }

sub read_line {
    my $self = shift;
    my ($next, $prompt) = @_;

    print $prompt;
    return scalar <>;
}

(my $PREFIX = <<'PREFIX') =~ s/__PACKAGE__/__PACKAGE__/ge;
BEGIN {
    $^H = $__PACKAGE__::default_hints;
    %^H = %$__PACKAGE__::default_hinthash;
    ${^WARNING_BITS} = $__PACKAGE__::default_warning_bits;
}
PREFIX

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    my $env = { map { %$_ } @{ $self->{env} } };

    my $prefix = "package $self->{package};\n$PREFIX";

    return eval_closure(
        source      => "sub {\n$prefix;\n$line\n}",
        terse_error => 1,
        environment => $env,
        %args,
    );
}

sub lexical_environment {
    my $self = shift;
    my ($env) = @_;
    push @{ $self->{env} }, $env;
}

sub package {
    my $self = shift;
    my ($package) = @_;
    $self->{package} = $package;
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

sub loop {
    my $self = shift;
    my ($continue) = @_;

    $continue = 0 if $self->{quit};

    return $continue;
}

=begin Pod::Coverage

  new
  command_q

=end Pod::Coverage

=cut

1;
