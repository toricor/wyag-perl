package WYAG::Resource::Object;

use strict;
use warnings;
use feature qw/say state/;

use Compress::Zlib qw/uncompress/;
use Data::Validator;
use Digest::SHA1 qw/sha1_hex/;
use File::Spec;
use Hash::Ordered;

use WYAG::MouseType qw/Bool GitObject GitObjectKind SHA1/;
use WYAG::GitRepository;
use WYAG::GitObject::Commit;
use WYAG::GitObject::Tree;
use WYAG::GitObject::Tag;
use WYAG::GitObject::Blob;
use WYAG::Resource::File;

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

    # build header
    my $result = $object->fmt() . " $len\x00$data";
    # e.g. 6e245b9cd18643f5b2b38852a8320d7b557d3f8e
    my $digest = sha1_hex($result);

    if ($actually_write_fg) {
        # TODO
        say 'cannot write a file yet';
        # compress as a zip
        # save in .git/objects/6e/245b9cd18643f5b2b38852a8320d7b557d3f8e
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
    my $compressed = WYAG::Resource::File->read($path);
    my $raw = Compress::Zlib::uncompress($compressed);

    my ($type, $size) = ($raw =~ /(^commit|tree|tag|blob) (\d+)\x00/);
    die "malformed object: bad length $sha1" unless $size == length($raw) - length($type) - length($size) - 2;

    my $content = substr($raw, length($type) + length($size) + 2);

    return $class->_build_object($type, $repo, $content);
}

sub build_object {
    state $v; $v //= Data::Validator->new(
        fmt        => GitObjectKind,
        repository => 'Maybe[WYAG::GitRepository]',
        raw_data   => 'Str',
    )->with(qw/Method/);
    my ($class, $args) = $v->validate(@_);
    my ($fmt, $repo, $raw_data) = @$args{qw/fmt repository raw_data/};

    return $class->_build_object($fmt, $repo, $raw_data);
}

sub _build_object {
    my ($class, $type, $repo, $content) = @_;

    return WYAG::GitObject::Commit->new(repo => $repo, raw_data => $content) if ($type eq 'commit');
    return WYAG::GitObject::Tree->new(repo => $repo, raw_data => $content)   if ($type eq 'tree');
    return WYAG::GitObject::Tag->new(repo => $repo, raw_data => $content)    if ($type eq 'tag');
    return WYAG::GitObject::Blob->new(repo => $repo, raw_data => $content)   if ($type eq 'blob');
    die 'unreachable: invalid object type is detected.';
}

# Key-Value List with Message
sub kvlm_parse {
    my ($class, $raw, $start, $dct) = @_;

    unless (defined $dct) {
        $dct = Hash::Ordered->new();
    }

    my $spc = index($raw, " ", $start);
    my $nl  = index($raw, "\n", $start);

    if ($spc < 0 || $nl < $spc) {
        #die 'invalid line' unless $nl == $start;
        $dct->set("\n" => substr($raw, $start+1));
        return $dct;
    }

    # recursive case
    my $key = substr($raw, $start, $start + $spc);
    my $end = $start;

    while (1) {
        $end = index($raw, "\n", $end+1);
        last if substr($raw, $end+1, 1) ne " ";
    }

    my $value = substr($raw, $spc+1);
    $value =~ s/\\n /\\n/g;

    if ($dct->exists($key)) {

        $dct->set($key => [$dct->get($key) => $value]);
    } else {
        $dct->set($key => $value);
    }

    return $class->kvlm_parse($raw, $end+1, $dct);
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