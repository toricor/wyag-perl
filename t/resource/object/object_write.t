use strict;
use warnings;

use Test::Spec;
use File::Temp;

use WYAG::Resource::Object;
use WYAG::GitObject::Blob;
use WYAG::GitRepository;

describe 'about object_write' => sub {
    context 'when actually_write = False' => sub {
        my $sha1;
        before all => sub {
            my $dir = File::Temp->newdir();
            mkdir $dir->dirname . ".git" or die 'cannot make .git dir';

            my $repo = WYAG::GitRepository->new(worktree => $dir->dirname);
            my $git_object = WYAG::GitObject::Blob->new(repo => $repo, raw_data => "a\x00あ", size => 3);

            my $actually_write_fg = 0;
            $sha1 = WYAG::Resource::Object->object_write(+{
                object            => $git_object,
                actually_write_fg => $actually_write_fg,
            });
        };

        it 'should match returned sha1 value' => sub {
            is $sha1, '03e8b884e2d8ca113aa8ec3dc7cc91ce2b2a4dc2';
        };
    };

    context 'when actually_write = True' => sub {
        it 'should match returned sha1 value';
        it 'shouled write a file';
    };
};

runtests unless caller;