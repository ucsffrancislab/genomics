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
	module load CBI kallisto
fi
set -x

ARGS=$*



#	Search for the output file
while [ $# -gt 0 ] ; do
	case $1 in
		-o|--output-dir)
			shift; output=$1; shift;;
		*)
			shift;;
	esac
done


f=${output}
#
#	NOTE that kallisto's output is a directory, not a file so the condition is -d not -f
#
#if [ -f $f ] && [ ! -w $f ] ; then
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	echo "Running kallisto"

	kallisto $ARGS

	kallistostatus=$?

	chmod a-w $f

	if [ $kallistostatus -ne 0 ] ; then
		echo "Kallisto failed." 
		mv ${f} ${f}.FAILED
	fi

fi

