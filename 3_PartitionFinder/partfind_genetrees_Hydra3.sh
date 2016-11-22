#!/bin/sh

# Michael W. Lloyd
# 22 Nov 2016

# This script will sequentially run Version-2.0.0 of PartitionFinder (https://github.com/brettc/partitionfinder/releases/latest)
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

workdir=$(myreadlink  $1)

if [ -d "./logs" ]; then
  # Control will enter here if $DIRECTORY exists.
else 
	mkdir ./logs
fi

for ARQ in $workdir/*_OUT/

do

locus=`basename "$ARQ"`;

qsub -pe mpich 8 -q sThC.q -N pf_$locus -S /bin/sh -e ./logs/$locus.job.err -o ./logs/$locus.job.out -cwd -m aes pf_job.job $ARQ

done
