use strict;
use warnings;

use Test::Spec;
use WYAG::Resource::Object;

describe 'about kvlm_parse' => sub {
    context 'early return' => sub {
        context 'no space' => sub {
            my $oh;
            before all => sub {
                $oh = WYAG::Resource::Object->kvlm_parse("\nblob", 0);
            };
            it 'should return ordered dict' => sub {
                my ($k, $v) = $oh->shift();
                is $v, 'blob';
            };
        };

        context 'new line before space' => sub {
            my $oh;
            before all => sub {
                $oh = WYAG::Resource::Object->kvlm_parse("\nhoge fuga", 0);
            };
            it 'should return ordered dict' => sub {
                my ($k, $v) = $oh->shift;
                is $v, 'hoge fuga';
            };
        };
    };

    context 'recursive case' => sub {
        my $oh;
        before all => sub {
            my $s = <<'EOS';
tree 7897f8cd506e4ddbba8531799fcb76bb2cb36d41
parent a33da60ef9f44d70e3d9156820bfd9506e281f67
author toricor <irotoridoritoriyaben@yahoo.co.jp> 1595691699 +0900
committer GitHub <noreply@github.com> 1595691699 +0900
gpgsig -----BEGIN PGP SIGNATURE-----

wsBcBAABCAAQBQJfHFKzCRBK7hj4Ov3rIwAAdHIIAKLywyK/i80IkdN4hyfxUolL
sdpFbcJtjFq8pQq7ETW4pYf+SGLOkRBZU4Fv/J0S1x4TtK78o9rkiEAwa9Sz1+Cq
Mm56wZa387Ipo7dXj68XaDAOlucpVmprzuvQgSpu8PjTFQx6kAT88oMibAjNToQ0
GSIr3Ybo2ZUcwnfl7o5hfkqzPXh2UHVA9i+YTRMz0V663BtcWmNd/2dgY2+k4rga
GkXnCz1/Uzt2Y9l8rM7+TFN6/4o5sCFCAn6DX7qiiQ+wlahBNhW1dlwyjxDW1u9f
eOfrsRxFPHNxXIIGQajhxppOD0VurWiTi9QRBPjrIE1iPpqjLsiKARQ7AoX/HUI=
=nSf/
-----END PGP SIGNATURE-----


Update README.md
EOS
            $oh = WYAG::Resource::Object->kvlm_parse($s, 0);
        };
        it 'should parse the typical commit';
    };
};

runtests unless caller;