package WYAG::GitObject::Blob;
use strict;
use warnings;

use Mouse;
with 'WYAG::GitObject::Role::TypeIdentifiable';
with 'WYAG::GitObject::Role::Sized';
with 'WYAG::GitObject::Role::Serializable';
with 'WYAG::GitObject::Role::Deserializable';

use WYAG::MouseType qw/Str UInt/;

has repo => (
    is  => 'rw',
    isa => 'Maybe[WYAG::GitRepository]',
);

sub size {
    my $self = shift;
    return length($self->raw_data);
}

has raw_data => (
    is => 'rw',
    isa => Str,
    default => '',
);

sub fmt { 'blob' }

sub serialize {
    my $self = shift;
    return $self->raw_data;
}

sub deserialize {
    die 'unimplemented';
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;