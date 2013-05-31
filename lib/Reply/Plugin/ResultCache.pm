package Reply::Plugin::ResultCache;
use strict;
use warnings;

use base 'Reply::Plugin';

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{results} = [];

    return $self;
}

sub compile {
    my $self = shift;
    my ($next, $line, %args) = @_;

    $args{environment} ||= {};
    $args{environment}{'@res'} = $self->{results};

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

    return '$res[' . $#{ $self->{results} } . '] = ' . $result;
}

1;
