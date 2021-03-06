#!/bin/sh

# Michael W. Lloyd
# 22 Nov 2016

# This script will sequentially run Version-2.0.0 of PartitionFinder (https://github.com/brettc/partitionfinder/releases/tag/v2.0.0)
# Python 2.7 is required for this. 
# The installation of PartitionFinder requires a number of Python dependencies. Ensure they are installed, and that PartionFinder.py runs properly. 

PYV=`python -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";`
if [[ $(python --version 2>&1) == *2.7* ]]; then
  echo "Running python 2.7";
  else
  echo Current Python Verson is $PYV. Required Version is 2.7. Correct your path to point at python 2.7 and try again.
  exit 1 
fi

me=`basename "$0"`

function myreadlink() {
  (
  cd $(dirname $1)         # or  cd ${1%/*}
  echo $PWD/$(basename $1) # or  echo $PWD/${1##*/}
  )
}

if [ $# -ne 4 ]; then
    echo Script needs directory input.
    echo Script usage: $me [./path/to/PartitionFinder.py] [./path/to/pf_jobgen_output] [./path/to/SWSCEN.py] [#threads to use]
    exit 1
fi

re='^[0-9]+$'
if ! [[ $4 =~ $re ]] ; then
   echo "error: you provided something other than a number for threads" >&2; exit 1
fi

partfind=$(myreadlink $1)
workdir=$(myreadlink  $2)
swscen=$(myreadlink $3)

for ARQ in $workdir/*_OUT/

	do

  hold_locus=`basename "$ARQ"`;
  locus=$(echo $hold_locus| cut -d'_' -f 1)

  eval python $swscen $ARQ.nexus

  #rename $ARQ/$locus.nexus_entropy_partition_finder.cfg, $ARQ/partition_finder.cfg;
	mv $ARQ/$locus.nexus_entropy_partition_finder.cfg $ARQ/partition_finder.cfg
	
	eval python $partfind $ARQ$locus.nexus --raxml --cmdline-extras -T $4
	# This will run on a local machine. 

done
