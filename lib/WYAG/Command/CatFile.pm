package WYAG::Command::CatFile;
use strict;
use warnings;
use feature qw/say state/;

use Mouse;
with 'WYAG::Command::Role::Runnable';

use Data::Validator;

use WYAG::MouseType qw/SHA1 HashRef GitObject/;
use WYAG::Resource::Object qw/repo_find/;

sub run {
    state $v; $v //= Data::Validator->new(
        sha1   => SHA1,
        option => HashRef,
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($sha1, $option) = @$args{qw/sha1 option/};

    my $git_object = WYAG::Resource::Object->object_read(+{
        repository => repo_find(),
        sha1       => $sha1,
    });

    say $class->format(git_object => $git_object, option => $option);
}

sub format {
    state $v; $v //= Data::Validator->new(
        git_object => GitObject,
        option     => HashRef,
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($git_object, $option) = @$args{qw/git_object option/};

    if ($option->{type}) {
        return $git_object->fmt();
    }
    if ($option->{pretty_print}) {
        return $git_object->serialize();
    }
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;