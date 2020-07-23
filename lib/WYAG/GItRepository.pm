package WYAG::GitRepository;
use strict;
use warnings;

use Mouse;
use File::Spec;

# path
has worktree => (
    is       => 'ro',
    isa      => 'Str',
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