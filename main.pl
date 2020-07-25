use strict;
use warnings;

use lib './lib';
use feature qw/say/;


use Getopt::Long::Subcommand;

use WYAG::GitObject::Commit;
use WYAG::GitObject::Tree;
use WYAG::GitObject::Tag;
use WYAG::GitObject::Blob;
use WYAG::GitRepository;

use WYAG::Command::CatFile;
use WYAG::Command::HashObject;

use WYAG::Resource::Object;

sub main {
    my %cat_file_opt;
    my %hash_object_opt;

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
                options => +{
                    t => +{
                        handler => \$hash_object_opt{t},
                    },
                    w => +{
                        handler => \$hash_object_opt{w},
                    }, 
                },
            },
        },
    );
    die "GetOptions failed!\n" unless $res->{success};
    die "do not set cat-file -t and -p options simultaneously" if $cat_file_opt{t} && $cat_file_opt{p};

    if (scalar(@{$res->{subcommand}}) > 0) {
        if ($res->{subcommand}->[0] eq 'cat-file') {
            my $sha1 = $ARGV[0]
                or die 'git cat-file needs SHA1 hash as arg';

            WYAG::Command::CatFile->run(+{
                sha1   => $sha1,
                option => \%cat_file_opt,
            });
        }
        elsif ($res->{subcommand}->[0] eq 'hash-object') {
            my $path = $hash_object_opt{t} ? $ARGV[1] : $ARGV[0];
            open(my $fh, "<:raw", $path) or die $!;

            my $data;
            while (read $fh, my $buf, 16) {
                $data .= $buf;
            }
            close $fh;
            my $size = length($data);

            my ($obj, $repo);
            if ($hash_object_opt{t}) {
                my $fmt = $ARGV[0];
                if ($fmt eq 'commit') {
                    $obj = WYAG::GitObject::Commit->new(repo => undef, size => $size, raw_data => $data);
                } elsif ($fmt eq 'tree') {
                    $obj = WYAG::GitObject::Tree->new(repo => undef, size => $size, raw_data => $data);
                } elsif ($fmt eq 'tag') {
                    $obj = WYAG::GitObject::Tag->new(repo => undef, size => $size, raw_data => $data);
                } elsif ($fmt eq 'blob') {
                    $obj = WYAG::GitObject::Blob->new(repo => undef, size => $size, raw_data => $data);
                } else {
                    die 'invalid type';
                }
            } elsif ($hash_object_opt{w}) {
                $repo = WYAG::GitRepository->new(worktree => '.');
                $obj = WYAG::GitObject::Blob->new(repo => $repo, size => $size, raw_data => $data);
            } else {
                die 'unreachable!';
            }

            WYAG::Command::HashObject->run(+{
                object => $obj,
                option => \%hash_object_opt,
                repo   => $repo,
            });
        }
    }
}

main();

1;