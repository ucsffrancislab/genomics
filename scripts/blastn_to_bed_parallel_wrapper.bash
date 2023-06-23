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
	echo $0 *fasta
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SBATCH_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	db=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts
	extension=".fasta"	#_R1.fastq.gz"
	word_size=10
	evalue=0.001

	while [ $# -gt 0 ] ; do
		case $1 in
			--array*)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			-word_size)
				shift; word_size=$1; shift;;
			-evalue)
				shift; evalue=$1; shift;;
			-db)
				shift; db=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done
	
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI #samtools bwa bedtools2 cufflinks star/2.7.7a
	fi
	
	date
	

	mkdir -p ${OUT}

	echo "Using array_file :${array_file}:"

	echo
	echo "ext : ${extension}"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x


	while read fasta ; do

		echo blastn_to_bed.bash \
				--out ${OUT} \
				--extension ${extension} \
				-db ${db} \
				-evalue ${evalue} \
				-word_size ${word_size} \
				${fasta}

				#-query ${fasta} \

	done < ${array_file} > ${array_file}.commands

	#| parallel -j ${threads}

	parallel -j ${threads} < ${array_file}.commands


	date


else

	date=$( date "+%Y%m%d%H%M%S%N" )
	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array ${array_file} "
	
	threads=64

	while [ $# -gt 0 ] ; do
		case $1 in
			-t|--threads)
				shift; threads=$1; shift;;
			-o|--out|-e|--extension|-word_size|-evalue|-db)
				array_options="${array_options} $1 $2"; shift; shift;;
			-h|--help)
				usage;;
			-*)
				array_options="${array_options} $1"
				shift;;
			*)
				echo "Unknown param :${1}: Assuming file"; 
				realpath --no-symlinks $1 >> ${array_file}; shift;;
		esac
	done

	#	True if file exists and has a size greater than zero.
	if [ -s ${array_file} ] ; then

		# using M so can be more precise-ish
		mem=$[threads*7500]M
		scratch_size=$[threads*28]G	#	not always necessary

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs

		sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
			--job-name="$(basename $0)" \
			--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} \
			--output=${PWD}/logs/$(basename $0).${date}.out.log \
				$( realpath ${0} ) ${array_options}

	else

		echo "No files given"
		usage

	fi

fi

