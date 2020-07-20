use Getopt::Long::Subcommand;
use feature qw/say/;

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
    p $res;
    p %cat_file_opt;
    p @ARGV;
}

main();

1;