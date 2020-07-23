package WYAG::Command::CatFile;
use strict;
use warnings;
use Mouse;
with 'WYAG::Command::Role::Runnable';

use feature qw/state/;
use Data::Validator;

use WYAG::MouseType qw/HashRef GitObject/;

sub run {
    state $v; $v //= Data::Validator->new(
        target => GitObject,
        option => HashRef,
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($git_object, $option) = @$args{qw/target option/};

    use DDP;
    p $git_object;
    warn 'Command::CatFile#run';

    return $git_object->serialize();
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;