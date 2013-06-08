package Reply::Plugin;
use strict;
use warnings;
# ABSTRACT: base class for Reply plugins

=head1 SYNOPSIS

  package Reply::Plugin::Foo;
  use strict;
  use warnings;

  use base 'Reply::Plugin';

  # ...

=head1 DESCRIPTION

A L<Reply> plugin is an object which adds some functionality to a Reply
instance by implementing some specific methods which the Reply object will call
at various points during execution. Plugins may implement as many callback
methods as necessary to implement their functionality (although the more
callbacks a given plugin implements, the more likely it is that the plugin may
be more useful as multiple independent plugins).

Callback methods have two potential calling conventions:

=over 4

=item wrapped

Wrapped plugins receive a coderef as their first argument (before any arguments
to the callback itself), and that coderef can be used to call the next callback
in the list (if more than one plugin implements a given callback). In
particular, this allows calling the next plugin multiple times, or not at all
if necessary. Wrapped plugins should always call their coderef in list context.
All plugins listed below are wrapped plugins unless indicated otherwise.

=item chained

Chained plugins receive a list of arguments, and return a new list of arguments
which will be passed to the next plugin in the chain. This allows each plugin a
chance to modify a value before it's actually used by the repl.

=back

=head2 CALLBACKS

=over 4

=item prompt

Called to determine the prompt to use when reading the next line. Takes no
arguments, and returns a single string to use as the prompt. The default
implementation returns C<< ">" >>

=item read_line

Called to actually read a line from the user. Takes no arguments, and returns a
single string. The default implementation uses the C<< <> >> operator to read a
single line from the user.

=item command_C<$name> (chained)

If the line read from the user is of the form C<"#foo args...">, then plugins
will be searched for a callback method named C<command_foo>. This callback
takes a single string containing the provided arguments, and returns a new line
to evaluate instead, if any.

=item mangle_line (chained)

Modifies the line read from the user before it's evaluated. Takes the line as a
string and returns the modified line.

=item compile

Compiles the string of Perl code into a coderef. Takes the line of code as a
string and a hash of extra parameters, and returns the coderef to be executed.
The default implementation uses L<Eval::Closure> to compile the given string.
The extra parameters are passed directly to the C<eval_closure> call.

=item execute

Executes the coderef which has just been compiled. Takes the coderef and a list
of parameters to pass to it, and returns the list of results returned by
calling the coderef. The default implementation just calls the coderef
directly.

=item mangle_error (chained)

If the C<compile> or C<execute> callbacks throw an exception, this callback
will be called to modify the exception before it is passed to C<print_error>.
It receives the exception and returns the modified exception.

=item print_error

If the C<compile> or C<execute> callbacks throw an exception, this callback
will be called to display it to the user. It receives the exception and returns
nothing. The default implementation just uses C<print> to print it to the
screen.

=item mangle_result (chained)

This callback is used to modify the result of evaluating the line of code
before it is displayed. It receives the list of results and returns a modified
list of results.

=item print_result

This callback displays to the user the results of evaluating the given line of
code. It receives the list of results, and returns nothing. The default
implementation just uses C<print> to print them to the screen.

=item loop (chained)

This callback is called at the end of each evaluation. It receives whether the
repl has been requested to terminate so far, and returns whether the repl
should terminate.

=back

=cut

sub new { bless {}, shift }

=for Pod::Coverage
  new

=cut

1;
