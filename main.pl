use strict;
use warnings;

use lib './lib';
use feature qw/say/;

use Getopt::Long::Subcommand;
use Compress::Zlib qw/uncompress/;
use Digest::SHA1 qw/sha1_hex/;
use File::Spec;

use WYAG::GitObject::Commit;
use WYAG::GitObject::Tree;
use WYAG::GitObject::Tag;
use WYAG::GitObject::Blob;
use WYAG::GitRepository;

use WYAG::Command::CatFile;

sub main {
    my %cat_file_opt;
    my $res = GetOptions(
        summary => 'learning about git internal files',
        options => +{
            'help|h|?' => {
                summary => 'Display help message',
                handler => sub {
                    my ($cb, $val, $res) = @_;
                    say "help has not implemented yet";
                    exit 0;
                },
            },
        },
        subcommands => +{
            'cat-file' => +{
                summary => 'Provide content or type and size information for repository objects',
                options => +{
                    t => +{
                        handler => \$cat_file_opt{t},
                    },
                    p => +{
                        handler => \$cat_file_opt{p},
                    }, 
                },
            },
            'hash-object' => +{
                summary => 'Compute object ID and optionally creates a blob from a file',
                options => +{},
            },
        },
    );
    die "GetOptions failed!\n" unless $res->{success};
    die "do not set cat-file -t and -p options simultaneously" if $cat_file_opt{t} && $cat_file_opt{p};

    my $result;
    if (scalar(@{$res->{subcommand}}) > 0) {
        if ($res->{subcommand}->[0] eq 'cat-file') {
            my $repo = repo_find();
            my $sha1 = $ARGV[0]
                or die 'git cat-file needs SHA1';
            my $git_object = object_read($repo, $ARGV[0]);

            $result = WYAG::Command::CatFile->run(+{
                target => $git_object,
                option => \%cat_file_opt,
            });
        }
    }

    say $result;
}

sub repo_find {
    my ($path) = @_;
    $path //= '.';

    if (-d File::Spec->catfile($path, '.git')) {
        return WYAG::GitRepository->new(worktree => $path);
    }

    my $parent = File::Spec->catfile($path, '..');
    if ($parent eq $path) {
        die 'No git directory.';
    } else {
        return;
    }
    return repo_find($parent);
}

# Compute path under repo's gitdir.
sub repo_path {
    my ($repo, @path) = @_;
    return File::Spec->catfile($repo->gitdir, @path);
}

sub repo_file {
    my ($mkdir, $repo, @path) = @_;
    $mkdir //= !!0;
    if (repo_dir($mkdir, $repo, @path[0..$#path-1])) {
        return repo_path($repo, @path);
    }
}

sub repo_dir {
    my ($mkdir, $repo, @path) = @_;
    my $path = repo_path($repo, @path);

    if (-d $path) {
        return $path;
    } else {
        die "Not a directory: $path";
    }

    if ($mkdir) {
        mkdir $path
            or die "cannot make dir $path: $!";
    } else {
        return;
    }
}

sub object_read {
    my ($repo, $sha1) = @_;

    my $path = repo_file(0, $repo, 'objects', substr($sha1, 0, 2), substr($sha1, 2));

    open(my $fh, "<:raw", $path) or die $!;

    my $bufs;
    while (read $fh, my $buf, 16) {
        $bufs .= $buf;
    }
    close $fh;

    my $raw = Compress::Zlib::uncompress($bufs);

    my ($type, $size) = ($raw =~ /(^commit|tree|tag|blob) (\d+)\x00/);
    # TODO: size check

    return WYAG::GitObject::Commit->new(repo => $repo, size => $size, raw_data => $raw) if ($type eq 'commit');
    return WYAG::GitObject::Tree->new(repo => $repo, size => $size, raw_data => $raw)   if ($type eq 'tree');
    return WYAG::GitObject::Tag->new(repo => $repo, size => $size, raw_data => $raw)    if ($type eq 'tag');
    return WYAG::GitObject::Blob->new(repo => $repo, size => $size, raw_data => $raw)   if ($type eq 'blob');
    die 'unreachable: invalid object type is detected.';
}

main();

1;