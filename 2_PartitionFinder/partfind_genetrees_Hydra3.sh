#!/bin/sh

# Michael W. Lloyd
# 22 Nov 2016

# This script will sequentially run Version-2.0.0 of PartitionFinder (https://github.com/brettc/partitionfinder/releases/latest)
# It should run on a grid system that accepts qsub commands. 


### NEED TO INCLUDE CHECK IF INPUT DIR EXISTS. ALSO NEED TO UPDATE TO ASK FOR A PATH TO SWSCEN.py

me=`basename "$0"`

function myreadlink() {
  (
  cd $(dirname $1)         # or  cd ${1%/*}
  echo $PWD/$(basename $1) # or  echo $PWD/${1##*/}
  )
}

if [ $# -ne 3 ]; then
    echo Script needs directory input.
    echo Script usage: $me [./path/to/pf_jobgen_output] [./path/to/job_file] [./path/to/SWSCEN.py]
    exit 1
fi

workdir=$(myreadlink  $1)
jobfile=$(myreadlink  $2)
swscen=$(myreadlink  $3)

mkdir -p ./logs

for ARQ in $workdir/*_OUT/

do

hold_locus=`basename "$ARQ"`;

locus=$(echo $hold_locus| cut -d'_' -f 1)

qsub -pe mpich 8 -q sThC.q -N pf_$locus -S /bin/sh -e ./logs/$locus.job.err -o ./logs/$locus.job.out -cwd $jobfile $ARQ $locus $swscen

done
