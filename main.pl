use strict;
use warnings;

use lib './lib';
use Getopt::Long::Subcommand;
use feature qw/say/;
use Compress::Zlib qw/uncompress/;
use Digest::SHA1 qw/sha1_hex/;

use WYAG::IO;

use WYAG::GitObject::Commit;
use WYAG::GitObject::Tree;
use WYAG::GitObject::Tag;
use WYAG::GitObject::Blob;

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
            my $file_path = WYAG::IO->build_object_path(sha1 => $ARGV[0]);
            my $git_object = read_and_build_git_object($file_path);

            $result = WYAG::Command::CatFile->run(+{
                target => $git_object,
                option => \%cat_file_opt,
            });
        }
    }

    say $result;
}

sub read_and_build_git_object {
    my ($file_path) = @_;

    my $raw = WYAG::IO->get_raw_data($file_path);
    my $uncompressed_data = Compress::Zlib::uncompress($raw);

    my ($type, $size) = ($uncompressed_data =~ /(^commit|tree|tag|blob) (\d+)\x00/);
    # TODO: size check

    return WYAG::GitObject::Commit->new($file_path, $uncompressed_data) if ($type eq 'commit');
    return WYAG::GitObject::Tree->new($file_path, $uncompressed_data)   if ($type eq 'tree');
    return WYAG::GitObject::Tag->new($file_path, $uncompressed_data)    if ($type eq 'tag');
    return WYAG::GitObject::Blob->new($file_path, $uncompressed_data)   if ($type eq 'blob');
    die 'unreachable: invalid object type is detected.';
}

main();

1;