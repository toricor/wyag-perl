#use strict;
use Getopt::Long::Subcommand;
use feature qw/say/;
use Compress::Zlib qw/uncompress/;
use Digest::SHA1 qw/sha1_hex/;

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

    use DDP;
    my $input_path = '.git/objects/22/33633418832240b615fa133ab84bb47d39969e';
    my $compressed_data = <COMPRESSED>;
    open(COMPRESSED, $input_path) or die $!;
    binmode COMPRESSED;

    my $raw = '';
    while ($compressed_data = <COMPRESSED>) {
        $raw .= $compressed_data;
    }
    close $compressed_data;

    my $uncompressed_data = Compress::Zlib::uncompress($raw);
    say $uncompressed_data;

    my ($type, $size) = ($uncompressed_data =~ /(^commit|tree|tag|blob) (\d+)\x00/);

    say $type;
    say $size;
}

main();

1;