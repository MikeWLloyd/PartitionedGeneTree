#!/bin/sh

# Michael W. Lloyd
# 22 Nov 2016

# This script sequentially runs RAxML on each locus. This assume the use of raxmlHPC installed someplace where your path statement can find it (e.g., /usr/local/bin/). 

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

for ARQ in $workdir/*_OUT/*.phy

	do
  hold_locus=`basename "$ARQ"`;
  locus=$(echo $hold_locus| cut -d'.' -f 1)
  dir=`dirname "$ARQ"`;
	output="$dir/$locus\_MS";

	eval raxmlHPC -f a -p 12345 -x 12341 -m GTRGAMMA -q $dir/aln.part -N 200 -s $ARQ -n Multiplestarts -w $output

done