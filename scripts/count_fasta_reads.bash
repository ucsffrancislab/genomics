#!/usr/bin/env bash
#SBATCH --export=NONE		# required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

#ARGS=$*

while [ $# -gt 0 ] ; do

	echo $1

	f=${1}.read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
#		if [ "${1: -3}" == ".gz" ] ; then
#			command="zcat ${1} "
#		else
#			command="cat ${1} "
#		fi
#		if [ "${1: -4}" == "q.gz" ] ; then
#			command="${command} | paste - - - - "
#		else
#			command="${command} | paste - - "
#		fi

		if [ "${1: -4}" == "q.gz" ] ; then
			command="zcat ${1} | paste - - - - "
		elif [ "${1: -4}" == "fqgz" ] ; then
			command="zcat ${1} | paste - - - - "
		elif [ "${1: -1}" == "q" ] ; then
			command="cat ${1} | paste - - - - "
		elif [ "${1: -4}" == "a.gz" ] ; then
			command="cat ${1} | paste - - "
		elif [ "${1: -1}" == "a" ] ; then
			command="cat ${1} | paste - - "
		else
			command="cat ${1} "
		fi
		command="${command} | wc -l"
		eval $command > ${f}
		chmod a-w $f
	fi

	shift

done

