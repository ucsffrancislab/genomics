#!/usr/bin/env bash
#SBATCH --export=NONE

hostname

if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI bowtie2
fi

date

bowtie2-build $*

date

