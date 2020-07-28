package WYAG::GitObject::Tree;
use strict;
use warnings;

use Mouse;
with 'WYAG::GitObject::Role::TypeIdentifiable';
with 'WYAG::GitObject::Role::Serializable';
with 'WYAG::GitObject::Role::Deserializable';

use WYAG::MouseType qw/UInt/;

has repo => (
    is  => 'rw',
    isa => 'Maybe[WYAG::GitRepository]',
);

has size => (
    is => 'ro',
    isa => UInt,
    default => 0,
);

has raw_data => (
    is => 'rw',
    isa => 'Defined',
    default => '',
);

sub fmt { 'tree' }

sub serialize {
    my $self = shift;
    return $self->raw_data;
    die 'unimplemented';
}

sub deserialize {
    die 'unimplemented';
}

1;