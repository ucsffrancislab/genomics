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
	module load CBI samtools
fi
set -x

while [ $# -gt 0 ] ; do

	echo $1

	f=${1}.mapped_pair_read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		samtools view -f64 ${1} 2> /dev/null | gawk '( !and($2,4) || !and($2,8) ){ print }' | wc -l > ${f}
		chmod a-w $f
	fi

	shift
done
