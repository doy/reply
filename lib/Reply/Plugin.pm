package main;
use strict;
use warnings;
# ABSTRACT: base class for Reply plugins

use mop;

use Reply::Util 'methods';

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

Callback methods have three potential calling conventions:

=over 4

=item wrapped

Wrapped callbacks receive a coderef as their first argument (before any
arguments to the callback itself), and that coderef can be used to call the
next callback in the list (if more than one plugin implements a given
callback). In particular, this allows calling the next plugin multiple times,
or not at all if necessary. Wrapped plugins should always call their coderef in
list context. All plugins listed below are wrapped plugins unless indicated
otherwise.

=item chained

Chained callbacks receive a list of arguments, and return a new list of
arguments which will be passed to the next plugin in the chain. This allows
each plugin a chance to modify a value before it's actually used by the repl.

=item concatenate

Concatenate callbacks receive a list of arguments, and return a list of
response values. Each plugin that implements the given callback will be called
with the same arguments, and the results will be concatenated together into a
single list, which will be returned. Callbacks for published messages are of
this type.

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

The hash of extra parameters is passed directly to C<eval_closure>.

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

Reply plugins can also communicate among each other via a pub/sub mechanism. By
calling the C<publish> method, all plugins which respond to the given message
(implement a method of the given name) will have that method called with the
given arguments, and all of the responses will be collected and returned. Some
messages used by the default plugins are:

=over 4

=item tab_handler ($line)

Plugins can publish this message when they want to attempt tab completion.
Plugins that respond to this message should return a list of potential
completions of the line which is passed in.

=item lexical_environment

Plugins which wish to modify the lexical environment should do so by
implementing this message, which should return a hashref of variable names
(including sigils) to value references. There can be more than one lexical
environment (each maintained by a different plugin), so plugins that wish to
inspect the lexical environment should do so by calling
C<< $self->publish('lexical_environment') >>, and then merging together all of
the hashrefs which are returned.

=item package

Plugins which wish to modify the currently active package should do so by
implementing this message, which should return the name of the current package.
Then, to access the currently active package, a plugin can call
C<< ($self->publish('package'))[-1] >>.

=back

Your plugins, however, are not limited to these messages - you can use whatever
messages you want to communicate.

=cut

class Reply::Plugin is closed, repr('HASH') {
    has $!publisher = die "publisher is required";

=method publish ($name, @args)

Publish a message to other plugins which respond to it. All loaded plugins
which implement a method named C<$name> will have it called with C<@args> as
the parameters. Returns a list of everything that each plugin responded with.

=cut

    method publish ($method, @args) {
        $!publisher->($method, @args);
    }

=method commands

Returns the names of the C<#> commands that this plugin implements. This can
be used in conjunction with C<publish> - C<< $plugin->publish('commands') >>
will return a list of all commands which are available in the current Reply
session.

=cut

    method commands {
        map { s/^command_//; $_ } grep { /^command_/ } methods($self);
    }
}

=for Pod::Coverage
  new

=cut

1;
