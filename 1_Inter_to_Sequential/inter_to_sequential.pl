#!/usr/bin/env perl
#using code found here: http://stackoverflow.com/a/15413458

# Michael W. Lloyd
# 22 Nov 2016

# Conversion of a directory of interleaved Phylip alignment files, to sequential Phylip files

use File::Basename;
my $name = basename($0);
use Cwd 'abs_path';

$num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "\nFAILED TO RUN!\nUSAGE: perl $name [directory/to/phylip-relaxed-interleaved] [output/dir/]\n";
    exit;
}

unless(mkdir "$ARGV[1]") {
	die "FAILED TO RUN!\nUnable to create directory $ARGV[1] because it already exits.\n";
}

my $dir = abs_path( $ARGV[0] );
my $out_dir = abs_path ( $ARGV[1] ); 

opendir(DIR, $dir) or die $!;

while (my $file = readdir(DIR)) {

    # We only want files                                                                                                                                                                                                             
    next unless (-f "$dir/$file");

    print "$file\n";

    open (DATA, "<", "$dir/$file") or die "can't open $dir/$file/\n";
    $firstline = <DATA>;
    @splitter = split(/ /, $firstline);
    my $num_species = $splitter[1];
    my $size = $splitter[2];
    my $i = 0;
    my @species;
    my @acids;
    my $max_length = 0;

    # first $num_species rows have the species name
    for ($i = 0; $i < $num_species; $i++) {   
	my @line = split /\s+/, <DATA>;
	chomp @line;
	
	$length = length($line[0]);
	if ($length > $max_length) {
	    $max_length = $length;
	}
	
	push @species, shift (@line);
	push @acids, join ("", @line);

    }

    # Get the rest of the AAs
    $i = 0;
    while (<DATA>) {
	chomp;
	$_ =~ s/\r//g; #remove \r

	next if !$_;

	$_ =~ s/\s+//g; #remove spaces
	$acids[$i] .= $_;
	$i = ++$i % $num_species;

    }

    # Print them
    
    open OUTPUT, ">", $out_dir."/".$file;
    
    print OUTPUT "$firstline";
    for ($i = 0; $i < $num_species; $i++) {
	
	$length = length($species[$i]);
	$difference = ($max_length - $length) + 2;
	
	print OUTPUT $species[$i];
	print OUTPUT ' ' x $difference;

	# uncomment next line if you want to remove the gaps ("-")
	#$acids[$i] =~ s/-//g;
	print OUTPUT $acids[$i], "\n";
    }
}
