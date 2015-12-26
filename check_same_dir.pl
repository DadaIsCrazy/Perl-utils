#!/usr/bin/perl -w

use 5.18.0;
$| = 1;

unless ( $#ARGV == 1 ) {
    say "$0: Needs exactly 2 directories as parameters.";
    exit 1;
}

$ARGV[0] =~ s/\/$// while ( $ARGV[0] =~ /\/$/);
$ARGV[1] =~ s/\/$// while ( $ARGV[1] =~ /\/$/);

my %differents_files;
my $cpt = 0;
my $nb_check = 0;

print "Differences found : $cpt";

same_files(@ARGV);
same_files($ARGV[1], $ARGV[0]);

sub same_files {
    my ($dir1, $dir2) = @_;
    $nb_check++;

    foreach my $file1 (glob("$dir1/*")) {
        my ($end) = $file1 =~ /$dir1(.*)/;
        my $file2 = "$dir2$end";
        
        if (-f $file1) {
            if (! -f $file2) {
                print "\rDifferences found : " . ++$cpt;
                $differents_files{$file1} = 2;
            } elsif (! same_content($file1, $file2) ) {
                print "\rDifferences found : " . ++$cpt;
                $differents_files{$file1} = 3  unless exists $differents_files{$file2};
            }
        }

        elsif (-d $file1) {
            if (-d $file2) {
                same_files($file1, $file2);
            } else {
                print "\rDifferences found : " . ++$cpt;
                $differents_files{$file1} = 1;
            }
        }
    }

}

sub same_content {
    my ($file1, $file2) = @_;
    open my $fp1, '<', $file1 or die $!;
    open my $fp2, '<', $file2 or die $!;
    foreach my $line1 (<$fp1>) {
        my $line2 = <$fp2>;
        unless ($line1 eq $line2) {
            close $fp1;
            close $fp2;
            return;
        }
    }
    close $fp1;
    close $fp2;
    return 1
}

print "\r" . " " x 40 . "\r";

my ($dirs, $files, $contents) = ("", "", "");
while (my ($file, $value) = (each %differents_files)) {
    $dirs     .= "\t$file\n" if $value == 1;
    $files    .= "\t$file\n" if $value == 2;
    $contents .= "\t$file\n" if $value == 3;
}

if ($dirs) {
    say "Missing directories:";
    print $dirs;
}
if ($files) {
    say "Missing files:";
    print $files;
}
if ($contents) {
    say "Differents contents:";
    print $contents;
}

say "\n$nb_check files or directories checked.";
say "$cpt differences found.\n";


