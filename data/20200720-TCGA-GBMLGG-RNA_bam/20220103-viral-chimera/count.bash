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

#		count.bash *.viral.bam

while [ $# -gt 0 ] ; do

	echo $1

	viruses=$( cat ${1}.aligned_sequence_counts.txt | awk '{print $2}' | sort | uniq )

	for v in ${viruses} ; do

		f=${1%.bam}.hg38.bam.${v}.count.txt
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			samtools view ${1} 2> /dev/null | grep ${v} | awk '{print "^"$1"\t"}' | uniq > ${1}.${v}.seqs

			samtools view -f64 ${1%.bam}.hg38.bam 2> /dev/null | grep -f ${1}.${v}.seqs | gawk '( !and($2,4) || !and($2,8) ){ print }' | wc -l > ${f}

			chmod a-w $f
		fi

	done

	shift
done
