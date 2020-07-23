package WYAG::GitObject::Blob;
use strict;
use warnings;

use Mouse;
with 'WYAG::GitObject::Role::Serializable';
with 'WYAG::GitObject::Role::Deserializable';

use WYAG::MouseType qw/Str UInt/;

has repo => (
    is  => 'rw',
    isa => 'WYAG::GitRepository',
    required => 1,
);

has size => (
    is => 'ro',
    isa => UInt,
    default => 0,
);

has raw_data => (
    is => 'rw',
    isa => Str,
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