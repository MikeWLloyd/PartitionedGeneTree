#!/usr/bin/env perl

# Michael W. Lloyd
# 22 Nov 2016

# Script for preparing directory structure and input configuration files for multiple loci for PartitionFinder and RAxML analysis. 
# Input required is a Phylip-Sequential file.
# If Interleaved Phylip files exist, use inter_to_sequential.pl script. 

use File::Copy qw(copy);
use File::Basename;
use File::Path qw(make_path);
use Cwd 'abs_path';
my $name = basename($0);

$num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "\nFAILED TO RUN!\nUSAGE: perl $name [directory/to/phylip-relaxed-sequential] [output_directory]\n";
    exit;
}

$abs_path_in = abs_path( $ARGV[0] );
$abs_path_out = abs_path ( $ARGV[1] ); 

unless(make_path("$abs_path_out")) {
	die "FAILED TO RUN!\nUnable to create directory $ARGV[1] because it already exits.$!\n";
}

opendir(DIR, $abs_path_in) or die $!;

while (my $file = readdir(DIR)) {

    # We only want files                                                                                                                                                                                                             
    next unless (-f "$abs_path_in\/$file");
	my $dirname = dirname($file);
    print "$file\n";
    
	$infile = "$abs_path_in\/$file";
	
    open INFILE, '<', "$infile" or die "can't open $infile/\n";
    my $firstline = <INFILE>;
    close INFILE;

    my @stats = split / /, $firstline;

    $alignment_size = pop @stats;
    chomp $alignment_size;                                                                                                                                                                                             

    @split = split(/\./, $file);

    make_path("$abs_path_out\/$split[0]\_OUT/$file\_MS");

    $new_file ="$abs_path_out\/$split[0]\_OUT/$file";

    copy("$infile",$new_file) or die "Copy failed: $!";

    open CONF, '>', "$abs_path_out\/$split[0]\_OUT/partition_finder.cfg";

    print CONF "alignment = $file;\n";
    print CONF "branchlengths = linked;\n";
    print CONF "models = all;\n";
    print CONF "model_selection = BIC;\n";
    print CONF '[data_blocks]'."\n";
    print CONF "All = 1-$alignment_size;\n";
    print CONF '[schemes]'."\n";
    print CONF "search = kmeans;\n";

    close CONF;

}
