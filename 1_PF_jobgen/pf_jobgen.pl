#!/usr/bin/env perl

# Michael W. Lloyd
# 22 Nov 2016

# Script for preparing directory structure and input configuration files for multiple loci for PartitionFinder and RAxML analysis. 
# Input required is a directory of nexus files.


use File::Copy qw(copy);
use File::Basename;
use File::Path qw(make_path);
use Cwd 'abs_path';
#
my $name = basename($0);

$num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "\nFAILED TO RUN!\nUSAGE: perl $name [directory/to/phylip-relaxed-sequential] [output_directory]\n";
    exit;
}

unless(make_path("$ARGV[1]")) {
	die "FAILED TO RUN!\nUnable to create directory $ARGV[1] because it already exits, or can't be created.$!\n";
}

$abs_path_in = abs_path( $ARGV[0] );
$abs_path_out = abs_path ( $ARGV[1] ); 

opendir(DIR, $abs_path_in) or die $!;

while (my $file = readdir(DIR)) {

    # We only want files                                                                                                                                                                                                             
    next unless (-f "$abs_path_in\/$file");
	my $dirname = dirname($file);
    
	$infile = "$abs_path_in\/$file";
	
    @split = split(/\./, $file);
    print "$split[0]\n";

    make_path("$abs_path_out\/$split[0]\_OUT/$split[0]\_MS");

    $new_file ="$abs_path_out\/$split[0]\_OUT/$file";
    $phylip_file="$abs_path_out\/$split[0]\_OUT/$file.phy";

    copy("$infile",$new_file) or die "Copy failed: $!";

    open PHYLIP, '>', "$phylip_file" or die "can't open $phylip_file/\n";

    open INFILE, '<', "$infile" or die "can't open $infile/\n";
    #my $firstline = <INFILE>;
 
    while (<INFILE>) {
        $line = $_;
        if ($. == 3) {
            @stats = split(/ /, $line);
            $ntax = substr $stats[1], 5;
            $nchar = substr $stats[2], 6, -2;
            print PHYLIP "$ntax $nchar\n";
        }
        if ($. >= 6 && $_ !~ m/\;/) {
            print PHYLIP $_;
        }
    }

    close INFILE;
    close PHYLIP;

    open NEWFILE, '>>', "$new_file" or die "can't open $new_file/\n";

    $locus_name = substr $file,0,-6;

    print NEWFILE "BEGIN SETS;\n";
    print NEWFILE "[loci]\n";
    print NEWFILE "charset '$locus_name' = 1-$nchar;\n";
    print NEWFILE "END;\n";

    close NEWFILE;
}
