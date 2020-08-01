package WYAG::Resource::File;

sub read {
    my ($class, $path) = @_;

    open(my $fh, "<:raw", $path) or die $!;

    my $bufs;
    while (read $fh, my $buf, 4096) {
        $bufs .= $buf;
    }
    close $fh;

    return $bufs;
}

sub write {
    my ($class, $path, $content) = @_;

    open(my $fh, ">:raw", $path) or die $!;
    print $fh $content;
    close $fh;
}

1;