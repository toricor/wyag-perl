requires 'Mouse';
requires 'Compress::Zlib';
requires 'Getopt::Long::Subcommand';
requires 'Digest::SHA1';

on develop => sub {
    requires 'Data::Printer';
};

on test => sub {
    requires 'Test::Spec';
};