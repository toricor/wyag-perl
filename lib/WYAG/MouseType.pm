package WYAG::MouseType;

use warnings;
use strict;

use Mouse::Util::TypeConstraints;

# called at `use MouseX::Types -declare`, so write this code before the use;
my $storage;
sub type_storage {
    $storage //= +{
        # export Mouse builtin types from this package;
        (map { $_ => $_  } Mouse::Util::TypeConstraints->list_all_builtin_type_constraints),
    };
    return $storage;
};

use MouseX::Types
    -declare => [
        qw/
            GitObject
        /,
    ];

# import builtin types
use MouseX::Types::Mouse qw/Int Str HashRef Object ArrayRef Maybe Undef/;

subtype GitObject,
    as Object(),
    where { ref($_) =~ /\AWYAG::GitObject::(Blob|Tag|Tree|Commit)\z/mo },
    message { "GitObject is WYAG::GitObject::(Blob|Tag|Tree|Commit). got: ". ref $_ };

no Mouse::Util::TypeConstraints;
1;
