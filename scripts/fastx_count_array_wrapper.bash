#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it


function usage(){
	set +x
	echo
	echo "Usage:"
	echo
	echo $0 path/*1.fastq.gz
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SLURM_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	extension="_R1.fastq.gz"
	outdir=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
				shift; array_file=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done


	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI #samtools #star/2.7.7a
	fi
	
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

	#base=$( basename $line .bam )
	#bam=${line}

	#echo
	#echo "base : ${base}"
	#echo "bam : $bam"
	#echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x

	#f=${bam%.bam}.read_count.txt
	f=${line}.read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		#samtools view $* -c -F2304 ${bam} > ${f}

		if [ "${line: -4}" == "q.gz" ] ; then
			command="zcat ${line} | paste - - - - "
		elif [ "${line: -4}" == "fqgz" ] ; then
			command="zcat ${line} | paste - - - - "
		elif [ "${line: -1}" == "q" ] ; then
			command="cat ${line} | paste - - - - "
		elif [ "${line: -4}" == "a.gz" ] ; then
			command="zcat ${line} | paste - - "
		elif [ "${line: -1}" == "a" ] ; then
			command="cat ${line} | paste - - "
		else
			command="cat ${line} "
		fi
		command="${command} | wc -l"
		eval $command > ${f}

		chmod a-w $f
	fi

	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array_file ${array_file} "
	
	threads=4
	array=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array)
				shift; array=$1; shift;;
			-@|--threads)
				shift; threads=$1; shift;;
			-h|--help)
				usage;;
			*)
				echo "Unknown param :${1}: Assuming file"; 
				realpath --no-symlinks ${1} >> ${array_file}; shift ;;
		esac
	done

	#	True if file exists and has a size greater than zero.
	if [ -s ${array_file} ] ; then

		mem=$[threads*7500]M
		scratch_size=$[threads*28]G

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs

		#--gres=scratch:${scratch_size} \

		[ -z "${array}" ] && array="1-${max}"

		set -x

		#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
		#	"hours:minutes:sec‐onds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
			--parsable --job-name="$(basename $0)" \
			--time=14-0 --nodes=1 --ntasks=${threads} --mem=${mem} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )
	
		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

