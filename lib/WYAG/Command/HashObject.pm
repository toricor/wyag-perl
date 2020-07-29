package WYAG::Command::HashObject;
use strict;
use warnings;
use feature qw/say state/;

use Mouse;
with 'WYAG::Command::Role::Runnable';

use Data::Validator;

use WYAG::MouseType qw/HashRef GitObject/;
use WYAG::Resource::Object;

sub run {
    state $v; $v //= Data::Validator->new(
        object => GitObject,
        option => HashRef,
        repo   => 'Maybe[WYAG::GitRepository]',
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($object, $option, $repo) = @$args{qw/object option repo/};

    my $sha1 = WYAG::Resource::Object->object_write(+{
        object            => $object,
        actually_write_fg => !!$repo,
    });

    say $sha1;
    return $sha1;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;