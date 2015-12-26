#!/usr/bin/perl

=head

                        DESCRIPTION

This script takes 2 directory names as parameters,
and copy the structure of the 1st into the 2nd.
Directories' content and file names will be copied, but files'
contents wont be. 

=cut

use strict; use warnings;
use 5.14.0;
use File::Path qw(make_path);
use File::Copy;
$| = 1;

my ($depth, $nofile, $verbose) = (~0 - 1, 0, undef);

# Checking if enough arguments were provided
unless (@ARGV) {
    usage("light");
}

# Checking if --help has been provided on command line
if ($ARGV[0] eq "--help") {
    usage();
}

# Checking the options
if ($ARGV[0] eq "-nf") {
    $nofile = 1; shift @ARGV;
    if ($ARGV[0] && $ARGV[0] =~ /^-d(\d+)$/) {
        $depth = $1; shift @ARGV;
    }
} elsif ($ARGV[0] =~ /^-d(\d+)$/) {
    $depth = $1; shift @ARGV;
    if ($ARGV[0] && $ARGV[0] eq "-nf") {
        $nofile = 1; shift @ARGV;
    }
}

# Preventing invalid options
foreach (@ARGV) {
    if (/^-/) {
        say "$0: invalid option '$_'";
        say usage("light");
    }
}

# Checking the arguments.
if ($#ARGV != 1) {
    say "$0: missing argument."; 
    usage("light");
}
my ($from, $to) = @ARGV;

unless (-d $from) {
    say "$0: the directory '$from' doesn't exist.";
    exit 1;
}

# Checking if the destination directory already exists.
if (-d $to) {
    print "The directory `$to` already exists. Do you wish to continue? [Y/n] ";
    my $rep = <STDIN>;
    unless ($rep eq "\n" || $rep eq "y\n" || $rep eq "Y\n") {
        say "$0: aborting.";
        exit 1;
    }
} else {
    make_path $to;
}


# Lauching the main treatment
print "Copy in progress... ";
print "\n" if $verbose;
copy_rec($from, $depth + 1);
say "[done]";


# ---------------------------------------------- #
#            Utilitary functions                 #
# ---------------------------------------------- #

# Main copy function.
sub copy_rec {
    my ($to_copy, $depth_loc) = @_;
    say "$to_copy ($depth_loc)" if $verbose; # TODO : implement verbose
    return if $depth_loc == 0;
    if (-d $to_copy) {
        make_path "$to/$to_copy";
        foreach my $file (glob("$to_copy/*")) {
            copy_rec($file, $depth_loc - 1);
        }
    } elsif (! $nofile) {
        open my $fp, ">$to/$to_copy";
        close $fp;
    }
}

# Display usage and exit the script.
# if an argument is provided, display short usage, else display full usage.
sub usage {
    say "Usage: $0 [-nf] [-d depth] <origin> <destination>";
    if (shift) {
        say "Try '$0 --help' for more information.";
    } else {
        say "\n" .
            "Options :\n" .
            "    -nf\t\t\tno file : do not copy files, only directories\n" .
            "    -d depth\t\tdefine depth of copy. The script breaks once depth \n\t\t\tis reached.\n" .
            "    --help\t\tdisplay this help and exit";
        exit 0;
    } 
    exit 1;
}
