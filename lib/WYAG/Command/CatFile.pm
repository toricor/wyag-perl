package WYAG::Command::CatFile;
use strict;
use warnings;
use feature qw/say/;

use Mouse;
with 'WYAG::Command::Role::Runnable';

use Data::Validator;

use WYAG::MouseType qw/HashRef GitObject/;

sub run {
    my $v = Data::Validator->new(
        target => GitObject,
        option => HashRef,
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($git_object, $option) = @$args{qw/target option/};

    return say $git_object->serialize();
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;