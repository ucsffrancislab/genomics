#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI plink2
fi
set -x

ARGS=$*

#	No easily computable output file so pick custom argument, pass on the rest

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--check)
			shift; output=$1; shift;;
		--out)
			SELECT_ARGS="${SELECT_ARGS} $1";
			shift; outbase=$1;
			SELECT_ARGS="${SELECT_ARGS} $1";
			shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	plink2 $SELECT_ARGS
	chmod a-w ${outbase}*
fi

#	untested

