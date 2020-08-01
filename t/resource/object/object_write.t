use strict;
use warnings;

use Test::Mock::Guard qw/mock_guard/;
use Test::Spec;
use File::Temp;
use File::Spec;

use WYAG::GitRepository;
use WYAG::Resource::Object;
use WYAG::GitObject::Blob;

my $output_path;
my $guard = mock_guard('WYAG::Resource::File', +{write => sub {
    my ($self, $path, $content) = @_;
    $output_path = $path;
}});

describe 'about object_write' => sub {
    context 'when actually_write = False' => sub {
        my ($sha1, $repo);
        before all => sub {
            $output_path = '';
            my $dir = File::Temp->newdir();
            mkdir $dir->dirname . '.git' or die 'cannot make .git dir';

            $repo = WYAG::GitRepository->new(worktree => $dir->dirname);
            my $git_object = WYAG::GitObject::Blob->new(repo => $repo, raw_data => "a\x00あ", size => 3);

            my $actually_write_fg = 0;
            $sha1 = WYAG::Resource::Object->object_write(+{
                object            => $git_object,
                actually_write_fg => $actually_write_fg,
            });
        };

        it 'should match returned sha1 value' => sub {
            warn 'first it';
            is $sha1, 'a5a01cf07c94c193ab53e52a7541090e5d5505d3';
        };

        it 'should not write the file' => sub {
            warn 'second it';
            is $guard->call_count('WYAG::Resource::File', 'write'), 0;
        };
    };

    context 'when actually_write = True' => sub {
        my ($sha1, $repo);
        before all => sub {
            $output_path = '';
            my $dir = File::Temp->newdir();
            mkdir $dir->dirname . '.git' or die 'cannot make .git dir';

            $repo = WYAG::GitRepository->new(worktree => $dir->dirname);
            my $git_object = WYAG::GitObject::Blob->new(repo => $repo, raw_data => "b\x00い", size => 3);

            my $actually_write_fg = 1;
            $sha1 = WYAG::Resource::Object->object_write(+{
                object            => $git_object,
                actually_write_fg => $actually_write_fg,
            });
        };
        it 'should match returned sha1 value' => sub {
            is $sha1, 'bff0772a1f169169058e78a097c80afff7569016';
        };
        it 'should write a file' => sub {
            my $expected_path = File::Spec->catfile($repo->gitdir, 'objects', 'bf', 'f0772a1f169169058e78a097c80afff7569016');
            is $guard->call_count('WYAG::Resource::File', 'write'), 1, 'write once';
            is $output_path, $expected_path;
        };
    };
};

runtests unless caller;