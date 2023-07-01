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
	module load CBI cutadapt
fi
set -x

ARGS=$*

output=""
output2=""
while [ $# -gt 0 ] ; do
	case $1 in
		-o|--output)
			shift; output=$1; shift;;
		-p|--output2)
			shift; output2=$1; shift;;
		*)
			shift;;
	esac
done

f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	cutadapt $ARGS > ${f}.cutadapt_summary.log
	chmod a-w $f
	chmod a-w ${f}.cutadapt_summary.log

	count_fasta_reads.bash $f
	average_fasta_read_length.bash $f

	if [ -n "${output2}" ] ; then
		chmod a-w $output2
		count_fasta_reads.bash $output2
		average_fasta_read_length.bash $output2
	fi

fi

