package WYAG::IO;

use strict;
use warnings;

use Data::Validator;
use WYAG::MouseType qw/SHA1/;

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

sub build_object_path {
    my $v = Data::Validator->new(
        sha1 => SHA1,
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);

    my $sha1 = $args->{sha1};
    return '.git/objects/'. substr($sha1, 0, 2) . '/' . substr($sha1, 2);
}

1;