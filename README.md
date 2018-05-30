# Individual Gene Tree / Locus Analysis Using [SWSCEN](https://github.com/Tagliacollo/PFinderUCE-SWSC-EN), [PartitionFinder-2.1.1](https://github.com/brettc/partitionfinder/releases/latest), [RAxML](https://github.com/stamatak/standard-RAxML) and [ASTRAL](https://github.com/smirarab/ASTRAL)

This series of scripts assumes you are starting with Phylip formated alignments for individual genes or loci. Each gene or locus is contained within an individual file, and all files are contained in a single directory.  

This can be achieved a number of ways; however, one way is from the [Phyluce](https://github.com/faircloth-lab/phyluce) pipeline. Here I assume you would pick up after the `phyluce_align_get_only_loci_with_min_taxa` step. If this is the case, you will need to remove the locus names from the alignments with: `phyluce_align_remove_locus_name_from_nexus_lines`
    
Once you have a directory containing individual nexus genes/locus files you pick up with PF_jobgen. 

**Note: that the 'local' versions of the scripts require additional testing. Please file an issue is the scripts are not working properly.**
    
## 1. pf_jobgen.pl

This script will prepare the directory structure and input configuration files for multiple loci for SWSCEN and PartitionFinder and the subsequently RAxML analysis.

The required input is a directory of nexus alignments.  


### Example call: 
    perl pf_jobgen.pl [directory/to/phylip-relaxed-sequential] [output_directory]
    
### If you wish to proceed with SWSCEN and partitionfinder, go to step 3. Else, proceed to step 5b.     

## 2. partfind\_genetrees\_local.sh


This script will sequentially run [SWSCEN](https://github.com/Tagliacollo/PFinderUCE-SWSC-EN) and then version-2.1.1 of [PartitionFinder](https://github.com/brettc/partitionfinder/releases/tag/v2.1.1)  
Python 2.7 is required for PartitionFinder and SWSC. Additionally SWSC requires a number of python modules to be installed. (biopython, numpy, pathlib2, and tqdm). See the documentation of SWSCEN for installation instructions. 

The installation of PartitionFinder-2.1.1 also requires a number of Python dependencies. 

Ensure that all dependencies for both SWSCEN and Partitionfinder are installed, and that SWSCEN.py and PartionFinder.py run properly before running the bash script.  

A second version of the bash script (partfind_genetrees_Hydra3.sh and pf_job.job) is included for cluster or grid computing systems. It is currently configured for systems that accept qsub commands, but could be modified to suit your needs.  

### Example call: 
    ./partfind_genetrees_local.sh [./path/to/PartitionFinder.py] [./path/to/pf_jobgen_output] [./path/to/SWSCEN.py] [#threads to use]
    
The path to the PartitionFinder script need not be an absolute path. If you have multiple cores (most do these days) include the number you want to dedicate to the analysis. You must specify a number...even if that number is 1. 

## 3. best\_scheme\_finder.pl

This script takes the resulting output from PartitionFinder for each locus, and generates the partition (.aln) file for use in RAxML. The file is placed in the directory with the alignment file.  
   
### Example call: 
    perl best_scheme_finder.pl [./path/to/pf_jobgen_output]
    
## 4a. raxml\_genetrees\_part\_local.sh

Assumes you have run steps 3 and 4. This script sequentially runs partitioned RAxML on each locus. This assume the use of raxmlHPC installed someplace where your path statement can find it (e.g., /usr/local/bin/).  
If a different version of raxml is required, modify the script to point at the version you require. You could also modify this to include multi-threaded version...

Again, I have included version for cluster or grid computing systems (raxml\_genetrees\_part\_Hydra3.sh and raxml\_job\_part\_Hydra3.job). They can be modified to suit your needs. 

### Example call: 
    ./raxml_genetrees_part_local.sh [./path/to/pf_jobgen_output]

## 4b. raxml\_genetrees\_nopart\local.sh

Assumes you have proceeded here from step 2. This script sequentially runs RAxML on each locus. This assume the use of raxmlHPC installed someplace where your path statement can find it (e.g., /usr/local/bin/).  
If a different version of raxml is required, modify the script to point at the version you require. You could also modify this to include multi-threaded version...

Again, I have included version for cluster or grid computing systems (raxml\_genetrees\_nopart\_Hydra3.sh and raxml\_job\_nopart\_Hydra3.job). They can be modified to suit your needs. 

### Example call: 
    ./raxml_genetrees_nopart_local.sh [./path/to/pf_jobgen_output]

    
## 5. best\_tree\_concat.pl

This script takes files resulting from a gene tree or individual locus RAxML analysis, and concatenates the best trees, and reorganize the bootstraps for analysis with Astral or other software (also into a structure that is easier to look at).  

There are a number of assumptions that are made here. Chief among them that you have followed all prior script steps to get here. The assumptions are:  

1. Loci/genes are organized into individual directories (see Example_Files/SAMPLEDIR directory)  
2. The individual directories contain a directory named in the following format: [locus/gene].additional-name-info  
3. In the [locus/gene].additional-name-info directory there are the following files: 'RAxML\_bestTree.Multiplestarts', 'RAxML\_bootstrap.Multiplestarts'  

The directory structure results from running the preceding script steps, but can be obtained in other ways.  

### Example call: 
    USAGE: perl best_tree_concat.pl [relative_path_to/directory_containing_locus/directories] [output_directory]  

###The output directory contains:  
* output\_test\_dir\_treeconcat.tre - a file containing the concatenated best trees (required Astral input file).  
* output\_test\_dir\_bootlocation.txt - a file that contains bootstrap files, one line per file. (required Astral input).  
* output\_test\_dir\_parsed\_locus\_list.txt - a file containing the names of the loci processed (for use in sanity checks).  
* ./boots - directory of individual bootstrap trees.  
* ./best - directory of individual best trees.

## 6. ASTRAL

Run ASTRAL per the manual (should you wish to). e.g.,:  

    java -Xmx4000M -jar ../astral.4.7.6.jar -i result_treeconcat.tre -b result_bootlocation.txt -r 100
    
    
## Example Files Provided

I have provided files from start to finish to provide examples of how the output looks if everything works properly. 

* ./nexus  
	This contains example nexus files and is the starting point for all subsequent steps. 
* ./PF\_RAxML\_Files  
	This is the workhorse directory that is initially generated in the pf_jobgen step and is used repeatedly for the rest of the script steps. This directory contains all the files for the remaining steps, and is complete to show what files are generated during the entire process.
* ./Astral_Infiles  
	This is the final directory output by best_tree_concat containing the files for use in ASTRAL, or other programs. 
