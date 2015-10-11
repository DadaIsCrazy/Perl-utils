#!/usr/bin/perl

# ----------------------------------------------------------- #
#                         DESCRIPTION                         #
#                                                             #
# This script takes 2 directory names as paramters,           #
# and copy the structure of the 1st one into the 1nd one.     #
# Directories content and file names will be copy, but files  #
# contents wont be.                                           #
#                                                             #
# ----------------------------------------------------------- #

use strict; use warnings;
use 5.14.0;
use File::Path qw(make_path remove_tree);
use File::Copy;
$| = 1;

# Checking for arguments.
if ($#ARGV != 1) {
    say "$0 error : expect 2 arguments. (" . ($#ARGV + 1) . " given)"; 
    say "Use : ./duplicate <from> <to>";
    exit 1;
}
my ($from, $to) = @ARGV;

# Checking if destination directory already exists.
if (-d $to) {
    print "Directory `$to` already exists. Do you wish to continue? [Y/n] ";
    my $rep = <STDIN>;
    unless ($rep eq "\n" || $rep eq "y\n" || $rep eq "Y\n") {
        say "$0 : aborting.";
        exit 1;
    }
} else {
    make_path $to;
}

# Main copy function.
# Note that the reccursion could lead to stackoverflow.
sub copy_rec {
    my ($to_copy) = @_;
    if (-d $to_copy) {
        make_path "$to/$to_copy";
        foreach my $file (glob("$to_copy/*")) {
            copy_rec($file);
        }
    } else {
        open my $fp, ">$to/$to_copy";
    }
}

# After the copy : move the files in the right directory.
sub finalize {
    foreach my $file (glob("$to/$from/*")) {
        move $file, $to;
    }
    remove_tree "$to/$from";
}


print "\nCopy in progress... ";

copy_rec($from);
finalize;

say "[done]\n";
