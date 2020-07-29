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
use WYAG::Resource::File;

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
                        handler => \$cat_file_opt{type},
                    },
                    p => +{
                        handler => \$cat_file_opt{pretty_print},
                    },
                },
            },
            'hash-object' => +{
                summary => 'Compute object ID and optionally creates a blob from a file',
                options => +{
                    t => +{
                        handler => \$hash_object_opt{type},
                    },
                    w => +{
                        handler => \$hash_object_opt{write},
                    }, 
                },
            },
        },
    );
    die "GetOptions failed!\n" unless $res->{success};
    die "do not set cat-file -t and -p options simultaneously" if $cat_file_opt{type} && $cat_file_opt{pretty_print};

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
            my ($path, $fmt) = _parse_args_for_hash_object(\%hash_object_opt, \@ARGV);
            my $data = WYAG::Resource::File->read($path);
            my $repo = WYAG::GitRepository->new(worktree => '.') if ($hash_object_opt{write});

            my $git_object;
            if ($hash_object_opt{type}) {
                $git_object = WYAG::Resource::Object->build_object(fmt => $fmt, repository => undef, raw_data => $data);
            } elsif ($hash_object_opt{write}) {
                $git_object = WYAG::Resource::Object->build_object(fmt => 'blob', repository => $repo, raw_data => $data);
            } else {
                die 'unreachable!';
            }

            WYAG::Command::HashObject->run(+{
                object => $git_object,
                option => \%hash_object_opt,
                repo   => $repo,
            });
        }
        else {
            die 'unreachable! (GetOptions will return early)';
        }
    }
    else {
        die 'args are needed' if scalar(@ARGV) == 0;
        die 'unreachable!';
    }
}

main();

sub _parse_args_for_hash_object {
    my ($hash_object_opt, $argv) = @_;
    my $path = $hash_object_opt->{type} ? $argv->[1] : $argv->[0];

    my $fmt;
    if ($hash_object_opt->{type}) {
        $fmt = $argv->[0];
    }

    return ($path, $fmt);
}

1;