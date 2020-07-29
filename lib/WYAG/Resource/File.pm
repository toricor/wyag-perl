package WYAG::Resource::File;

sub read {
    my ($class, $path) = @_;

    open(my $fh, "<:raw", $path) or die $!;

    my $bufs;
    while (read $fh, my $buf, 16) {
        $bufs .= $buf;
    }
    close $fh;

    return $bufs;
}

1;