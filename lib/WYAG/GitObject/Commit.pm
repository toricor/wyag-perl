package WYAG::GitObject::Commit;
use strict;
use warnings;

use Mouse;
with 'WYAG::GitObject::Role::TypeIdentifiable';
with 'WYAG::GitObject::Role::Serializable';
with 'WYAG::GitObject::Role::Deserializable';

has repo => (
    is  => 'rw',
    isa => 'Maybe[WYAG::GitRepository]',
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

sub fmt { 'commit' }

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