#!/usr/bin/env perl

# Michael W. Lloyd
# 22 Nov 2016

# This script takes the output from PartitionFinder for each locus, and generates the partition file for use in RAxML. The file is placed in the directory with the alignment file. 

use File::Find;
use File::Spec;
use Cwd 'abs_path';
use File::Basename;
my $name = basename($0);

$num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nFAILED TO RUN!\nUSAGE: perl $name [./path/to/pf_jobgen_output]\n";
    exit;
}

my $dir = abs_path( $ARGV[0] );

find(\&cat_file_name, "$dir");

sub cat_file_name {

    $file = $File::Find::name;

    next unless ($file =~ m/best_scheme.txt/);
    
    print "$file\n";

	my @dirs = File::Spec->splitdir($file);
	pop @dirs;
	pop @dirs;
	$taxon = $dirs[-1];
	my $newdir = File::Spec->catdir(@dirs);
	$output_file = $newdir."/aln.part";
	#print "$newdir\t$output_file\n";
 
	open (INFILE,  "<", $file);
	open (OUTFILE, ">", $output_file); 
     
	while (<INFILE>) {
		next until ($_ =~ /DNA, Subset/);
		print OUTFILE "$_";
	}
	close INFILE;
	close OUTFILE;
}