use strict;
use warnings;

use Compress::Zlib qw/uncompress/;

sub bin_dump {
    my ($path) = @_;
    open(my $fh, "<:raw", $path) or die $!;

    my $bufs;
    while (read $fh, my $buf, 16) {
        $bufs .= $buf;
    }
    close $fh;

    #print $bufs;
    my $uncompressed = Compress::Zlib::uncompress($bufs);
    print $uncompressed;
}

my $path = 'hoge';
#my $path = '.git/objects/8f/083b8b230e833e1ea7e679fac265ca6a422c02';
bin_dump($path);