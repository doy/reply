package main;

# XXX Eval::Closure imposes its own hints on things that are eval'ed at the
# moment, but this may be fixed in the future
BEGIN {
    our $default_hints = $^H;
    our $default_hinthash = { %^H };
    our $default_warning_bits = ${^WARNING_BITS};
}

use strict;
use warnings;

use mop;

use Eval::Closure 0.11;

(my $PREFIX = <<'PREFIX') =~ s/__PACKAGE__/__PACKAGE__/ge;
BEGIN {
    $^H = $__PACKAGE__::default_hints;
    %^H = %$__PACKAGE__::default_hinthash;
    ${^WARNING_BITS} = $__PACKAGE__::default_warning_bits;
}
PREFIX

class Reply::Plugin::Defaults extends Reply::Plugin {
    has $quit = 0;

    method prompt { "> " }

    method read_line ($next, $prompt) {
        print $prompt;
        return scalar <STDIN>;
    }

    method compile ($next, $line, %args) {
        my $env     = { map { %$_ } $self->publish('lexical_environment') };
        my $package = ($self->publish('package'))[-1];

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

    method execute ($next, $code, @args) {
        return $code->(@args);
    }

    method print_error ($next, $error) {
        print $error if defined $error;
    }

    method print_result ($next, @result) {
        print @result, "\n" if @result;
    }

    method command_q {
        $quit = 1;
        return '';
    }

    method loop ($continue) {
        $continue = 0 if $quit;
        $continue;
    }
}

=begin Pod::Coverage

  new
  command_q

=end Pod::Coverage

=cut

1;
