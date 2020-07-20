requires 'Mouse';
requires 'IO::Uncompress::Unzip';
requires 'Getopt::Long::Subcommand';

on develop => sub {
    requires 'Data::Printer';
};

on test => sub {
    requires 'Test::Spec';
};