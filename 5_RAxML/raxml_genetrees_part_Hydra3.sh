#!/bin/sh

# Michael W. Lloyd
# 22 Nov 2016

# This script sequentially runs RAxML on each locus. This assume the use of raxmlHPC installed someplace where your path statement can find it (e.g., /usr/local/bin/). 
# It should run on a grid system that accepts qsub commands. 

me=`basename "$0"`

function myreadlink() {
  (
  cd $(dirname $1)         # or  cd ${1%/*}
  echo $PWD/$(basename $1) # or  echo $PWD/${1##*/}
  )
}

if [ $# -ne 1 ]; then
    echo Script needs directory input.
    echo Script usage: $me [./path/to/pf_jobgen_output]
    exit 1
fi

workdir=$(myreadlink $1)

if [ -d "./logs" ]; then
  # Control will enter here if $DIRECTORY exists.
else 
	mkdir ./logs
fi

for ARQ in $workdir/*_OUT/*.phylip-relaxed

	do
	locus=`basename "$ARQ"`;
	dir=`dirname "$ARQ"`;

	qsub -pe orte 8 -q sThC.q -l mres=1.7G,h_data=1.7G,h_vmem=1.7G -N gtree_$locus -S /bin/sh -e ./logs/$locus.job.err -o ./logs/$locus.job.out -cwd -m aes raxml_job_part_Hydra3.job $ARQ $dir

done