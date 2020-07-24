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
use WYAG::Resource::Object;

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

    if (scalar(@{$res->{subcommand}}) > 0) {
        if ($res->{subcommand}->[0] eq 'cat-file') {
            my $sha1 = $ARGV[0]
                or die 'git cat-file needs SHA1 hash as arg';
            my $git_object = WYAG::Resource::Object->object_read(+{repository => repo_find(), sha1 => $sha1});

            WYAG::Command::CatFile->run(+{
                target => $git_object,
                option => \%cat_file_opt,
            });
        }
    }
}

main();

1;