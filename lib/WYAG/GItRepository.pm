package WYAG::GitRepository;
use strict;
use warnings;

use Mouse;
use File::Spec;

has worktree => (
    is       => 'ro',
    isa      => 'Str', # path
    required => 1,
);

has gitdir => (
    is      => 'ro',
    isa     => 'Str',
    builder => sub {
        my $self = shift;
        return File::Spec->catfile($self->worktree, '.git');
    },
);

no Mouse;
__PACKAGE__->meta->make_immutable;

1;