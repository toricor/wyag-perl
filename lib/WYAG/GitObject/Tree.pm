package WYAG::GitObject::Tree;
use strict;
use warnings;

use Mouse;
with 'WYAG::GitObject::Role::TypeIdentifiable';
with 'WYAG::GitObject::Role::Sized';
with 'WYAG::GitObject::Role::Serializable';
with 'WYAG::GitObject::Role::Deserializable';

use WYAG::MouseType qw/UInt/;

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
    isa => 'Defined',
    default => '',
);

sub fmt { 'tree' }

sub serialize {
    my $self = shift;
    return $self->raw_data;
}

sub deserialize {
    die 'unimplemented';
}

1;