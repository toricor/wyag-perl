package WYAG::Command::CatFile;
use strict;
use warnings;
use feature qw/say state/;

use Mouse;
with 'WYAG::Command::Role::Runnable';

use Data::Validator;

use WYAG::MouseType qw/SHA1 HashRef/;
use WYAG::Resource::Object qw/repo_find/;

sub run {
    state $v; $v //= Data::Validator->new(
        sha1   => SHA1,
        option => HashRef,
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($sha1, $option) = @$args{qw/sha1 option/};

    my $git_object = WYAG::Resource::Object->object_read(+{
        repository => repo_find(),
        sha1       => $sha1,
    });
use DDP;
p $git_object->raw_data;
    return $git_object->serialize();
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;