package WYAG::Resource::Object;

use strict;
use warnings;
use feature qw/state/;

use Compress::Zlib qw/uncompress/;
use Data::Validator;
use Digest::SHA1 qw/sha1_hex/;
use File::Spec;

use WYAG::MouseType qw/Bool GitObject SHA1/;

use Exporter 'import';
our @EXPORT_OK = qw/repo_find repo_path repo_dir repo_file/;

sub object_write {
    state $v; $v //= Data::Validator->new(
        object            => GitObject,
        actually_write_fg => +{isa => Bool, default => sub {1}},
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($object, $actually_write_fg) = @$args{qw/object actually_write_fg/};

    my $data = $object->serialize();
    my $len = length($data);

    # Add header
    my $result = "$object->fmt() $len\x00$data";
    my $digest = sha1_hex($data);

    if ($actually_write_fg) {
        # TODO
    }

    return $digest;
}

sub object_read {
    state $v; $v //= Data::Validator->new(
        repository => 'WYAG::GitRepository',
        sha1       => SHA1,
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($repo, $sha1) = @$args{qw/repository sha1/};

    my $path = repo_file(0, $repo, 'objects', substr($sha1, 0, 2), substr($sha1, 2));

    open(my $fh, "<:raw", $path) or die $!;

    my $bufs;
    while (read $fh, my $buf, 16) {
        $bufs .= $buf;
    }
    close $fh;

    my $raw = Compress::Zlib::uncompress($bufs);

    my ($type, $size) = ($raw =~ /(^commit|tree|tag|blob) (\d+)\x00/);
    die "malformed object: bad length $sha1" unless $size == length($raw) - length($type) - length($size) - 2;

    my $content = substr($raw, length($type) + length($size) + 2);

    return WYAG::GitObject::Commit->new(repo => $repo, size => $size, raw_data => $content) if ($type eq 'commit');
    return WYAG::GitObject::Tree->new(repo => $repo, size => $size, raw_data => $content)   if ($type eq 'tree');
    return WYAG::GitObject::Tag->new(repo => $repo, size => $size, raw_data => $content)    if ($type eq 'tag');
    return WYAG::GitObject::Blob->new(repo => $repo, size => $size, raw_data => $content)   if ($type eq 'blob');
    die 'unreachable: invalid object type is detected.';
}




# 
#
# repo utils
sub repo_find {
    my ($path) = @_;
    $path //= '.';

    if (-d File::Spec->catfile($path, '.git')) {
        return WYAG::GitRepository->new(worktree => $path);
    }

    my $parent = File::Spec->catfile($path, '..');
    if ($parent eq $path) {
        die 'No git directory.';
    } else {
        return;
    }
    return repo_find($parent);
}

# Compute path under repo's gitdir.
sub repo_path {
    my ($repo, @path) = @_;
    return File::Spec->catfile($repo->gitdir, @path);
}

sub repo_file {
    my ($mkdir, $repo, @path) = @_;
    $mkdir //= !!0;
    if (repo_dir($mkdir, $repo, @path[0..$#path-1])) {
        return repo_path($repo, @path);
    }
}

sub repo_dir {
    my ($mkdir, $repo, @path) = @_;
    my $path = repo_path($repo, @path);

    if (-d $path) {
        return $path;
    } else {
        die "Not a directory: $path";
    }

    if ($mkdir) {
        mkdir $path
            or die "cannot make dir $path: $!";
    } else {
        return;
    }
}

1;