package WYAG::Command::HashObject;
use strict;
use warnings;
use feature qw/say state/;

use Mouse;
with 'WYAG::Command::Role::Runnable';

use Data::Validator;

use WYAG::MouseType qw/Maybe GitObjectKind Str HashRef/;
use WYAG::Resource::Object;

sub run {
    state $v; $v //= Data::Validator->new(
        fmt      => Maybe[GitObjectKind],
        raw_data => Str,
        option   => HashRef,
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($fmt, $raw_data, $option) = @$args{qw/fmt raw_data option/};

    my ($git_object, $repo);
    if ($option->{type}) {
        $git_object = WYAG::Resource::Object->build_object(fmt => $fmt, repository => undef, raw_data => $raw_data);
    } elsif ($option->{write}) {
        $repo = WYAG::GitRepository->new(worktree => '.');
        $git_object = WYAG::Resource::Object->build_object(fmt => 'blob', repository => $repo, raw_data => $raw_data);
    } else {
        die 'unreachable!';
    }

    my $sha1 = WYAG::Resource::Object->object_write(+{
        object            => $git_object,
        actually_write_fg => !!$repo,
    });

    say $sha1;
}

no Mouse;
__PACKAGE__->meta->make_immutable;

1;