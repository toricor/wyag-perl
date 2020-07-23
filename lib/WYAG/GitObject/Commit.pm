package WYAG::GitObject::Commit;
use strict;
use warnings;

use Mouse;
with 'WYAG::GitObject::Role::Serializable';
with 'WYAG::GitObject::Role::Deserializable';

has repo => (
    is  => 'rw',
    isa => 'Str',
    default => '',
);

sub serialize {
    die 'unimplemented';
}

sub deserialize {
    die 'unimplemented';
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;