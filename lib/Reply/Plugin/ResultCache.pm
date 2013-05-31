package Reply::Plugin::ResultCache;
use strict;
use warnings;

use base 'Reply::Plugin';

sub new {
    my $class = shift;
    my %opts = @_;

    my $self = $class->SUPER::new(@_);
    $self->{results} = [];
    $self->{result_name} = $opts{variable} || 'res';

    return $self;
}

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    $args{environment} ||= {};
    $args{environment}{'@' . $self->{result_name}} = $self->{results};

    $next->($line, %args);
}

sub execute {
    my $self = shift;
    my ($next, @args) = @_;

    my @res = $next->(@args);
    if (@res == 1) {
        push @{ $self->{results} }, $res[0];
    }
    elsif (@res > 1) {
        push @{ $self->{results} }, \@res;
    }

    return @res;
}

sub mangle_result {
    my $self = shift;
    my ($result) = @_;

    return '$' . $self->{result_name} . '[' . $#{ $self->{results} } . '] = '
         . $result;
}

1;
