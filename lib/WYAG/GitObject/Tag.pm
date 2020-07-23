package WYAG::GitObject::Tag;
use strict;
use warnings;

use Mouse;
with 'WYAG::GitObject::Role::Serializable';
with 'WYAG::GitObject::Role::Deserializable';

has repo => (
    is  => 'rw',
    isa => 'WYAG::GitRepository',
    required => 1,
);

has size => (
    is => 'ro',
    isa => 'UInt',
    default => 0,
);


has raw_data => (
    is => 'rw',
    isa => 'Defined',
    default => '',
);

sub serialize {
    my $self = shift;
    return $self->raw_data;
    die 'unimplemented';
}

sub deserialize {
    die 'unimplemented';
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;