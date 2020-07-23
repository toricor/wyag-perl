package WYAG::GitObject::Blob;
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

has blob_data => (
    is => 'rw',
    isa => 'Defined',
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