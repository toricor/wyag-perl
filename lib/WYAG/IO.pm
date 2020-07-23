package WYAG::IO;

use strict;
use warnings;

sub get_raw_data {
    my ($class, $file_path) = @_;

    open(my $fh, "<:raw", $file_path) or die $!;
    binmode($fh);

    my $raw;
    while (read $fh, my $buf, 16) {
        $raw .= $buf;
    }
    close $fh;

    return $raw;
}

1;