#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
#if [ -n "$( declare -F module )" ] ; then
#	echo "Loading required modules"
#	module load CBI htslib samtools bowtie2
#fi
set -x	#	print expanded command before executing it


min=$1
max=$2

in=$3
out=$4



zcat $in | paste - - - - | awk -F"\t" -v min=${min} -v max=${max} '{
	split($1,a,"_")
	if( ( (a[2]+0) >= (min+0) ) && ( (a[2]+0) <= (max+0) ) ){
		print $1
		print $2
		print $3
		print $4
	}
}' | gzip > $out


chmod -w $out

count_fasta_reads.bash $out
average_fasta_read_length.bash $out

