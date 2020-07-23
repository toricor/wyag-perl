requires 'Mouse';
requires 'MouseX::Types';
requires 'Compress::Zlib';
requires 'Getopt::Long::Subcommand';
requires 'Digest::SHA1';
requires 'Data::Validator';

on develop => sub {
    requires 'Data::Printer';
};

on test => sub {
    requires 'Test::Spec';
};