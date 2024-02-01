#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI htslib samtools bowtie2
fi
set -x	#	print expanded command before executing it


f=${1}.pp.q40.aligned_sequence_counts.txt

if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Write-protected ${f} exists. Skipping."
else
	samtools view -f2 -F4 -q40 ${1} | awk '{print $3}' | sort --parallel=${SLURM_NTASKS} | uniq -c | sort -rn > ${f}
	chmod a-w ${f}
fi


f=${1}.q40.aligned_sequence_counts.txt

if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Write-protected ${f} exists. Skipping."
else
	samtools view -F4 -q40 ${1} | awk '{print $3}' | sort --parallel=${SLURM_NTASKS} | uniq -c | sort -rn > ${f}
	chmod a-w ${f}
fi

