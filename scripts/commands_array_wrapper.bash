#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
#set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it


function usage(){
	echo
	echo "Usage:"
	echo
	echo $0 --array_file my_commands
	echo
	echo $0 --array_file my_commands --array 25-75 --threads 8 --mem 10G --scratch 200G
	echo
	echo $0 --array_file my_commands --array 10,15,25-35 --threads 8 --mem 10G --scratch 200G
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
				shift; array_file=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done

	date
	
	line_number=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line_number :${line_number}:"

	#	Use a 1 based index since there is no line 0.

	echo "Using array_file :${array_file}:"

	line=$( sed -n "$line_number"p ${array_file} )
	echo $line

	if [ -z "${line}" ] ; then
		echo "No line at :${line_number}:"
		exit
	fi

	echo "Running"

	set -x  #       print expanded command before executing it

	eval "${line}"

	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Preparing array job :${date}:"
	
	threads=""
	array=""
	mem=""
	scratch=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array)
				shift; array=$1; shift;;
			--array_file)
				shift; array_file=$1; shift;;
			-t|--threads)
				shift; threads=$1; shift;;
			-m|--mem)
				shift; mem=$1; shift;;
			-s|--scratch)
				shift; scratch=$1; shift;;
			-h|--help)
				usage;;
			*)
				echo "Unknown param :${1}:";
				usage;;
		esac
	done

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI 	#	samtools star
	fi

	array_options="--array_file ${array_file} "

	#	True if file exists and has a size greater than zero.
	if [ -n "${array_file}" ] && [ -s "${array_file}" ] ; then
		
		if [ -z "${threads}" ] ;then
			threads=4
		fi

		if [ -n "${mem}" ] ;then
			# using M so can be more precise-ish
			mem_option="--mem=${mem} "
		else
			mem_option="--mem=$[threads*7500]M "
		fi

		if [ -n "${scratch}" ] ;then
			scratch_option="--gres=scratch:${scratch} "
		else
			scratch_option="--gres=scratch:$[threads*28]G "
		fi

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs

		set -x  #       print expanded command before executing it

		[ -z "${array}" ] && array="1-${max}"

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
			--parsable --job-name="$(basename $0)" \
			--time=10080 --nodes=1 --ntasks=${threads} ${mem_option} ${scratch_option} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )

		echo
		echo "Logging to ${PWD}/logs/$(basename $0).${date}-${array_id}_*.out.log"
		echo
		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

