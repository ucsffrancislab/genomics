#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it

#if [ $( basename ${0} ) == "slurm_script" ] ; then
##if [ -n "${SLURM_JOB_NAME}" ] ; then
#	script=${SLURM_JOB_NAME}
#else
#	script=$( basename $0 )
#fi
#
##	PWD preserved by slurm for where job is run? I guess so.
#arguments_file=${PWD}/${script}.arguments


#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then
#if [ $( basename ${0} ) == "slurm_script" ] ; then
if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SBATCH_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	#threads=${SLURM_NTASKS:-4}
	extension="_R1.fastq.gz"
	#IN="${PWD}/in"
	#OUT="${PWD}/out"

	while [ $# -gt 0 ] ; do
		case $1 in
			--array*)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; shift;;
			-r|--ref)
				shift; ref=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			*)
				echo "Unknown params :${1}:"; exit ;;
		esac
	done

	#mem=$[threads*7]
	#scratch_size=$[threads*28]

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools star/2.7.7a
	fi
	
	date
	
	mkdir -p ${OUT}

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

	base=$( basename $line ${extension} )
	#bam=${line}
	R1=${line}
	R2=${line/_R1./_R2.}

	echo
	echo "base : ${base}"
	echo "ext : ${extension}"
	echo "r1 : $R1"
	echo "r2 : $R2"
	#echo "bam : $bam"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x  #       print expanded command before executing it

	outFileNamePrefix="${OUT}/${base}."

	f="${outFileNamePrefix}Aligned.sortedByCoord.out.bam"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running STAR"

		STAR_scratch.bash \
			--runMode alignReads \
			--runThreadN ${threads} \
			--genomeDir ${ref} \
			--readFilesType Fastx \
			--readFilesIn ${R1} ${R2} \
			--readFilesCommand zcat \
			--outSAMstrandField intronMotif \
			--outSAMattributes Standard XS \
			--outSAMtype BAM SortedByCoordinate \
			--outFileNamePrefix ${outFileNamePrefix}

		#/francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a \

		samtools index ${f}
		chmod -w ${f}.bai

		##alignEndsType           Local
		##    string: type of read ends alignment
		##                        Local             ... standard local alignment with soft-clipping allowed
		##                        EndToEnd          ... force end-to-end read alignment, do not soft-clip
		##                        Extend5pOfRead1   ... fully extend only the 5p of the read1, all other ends: local alignment
		##                        Extend5pOfReads12 ... fully extend only the 5p of the both read1 and read2, all other ends: local alignment
		##    string: Cufflinks-like strand field flag
		##                                None        ... not used
		##                                intronMotif ... strand derived from the intron motif. This option changes the output alignments: reads with inconsistent and/or non-canonical introns are filtered out.

	fi

	date

else

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Preparing array job :${date}:"
	array_file=${PWD}/$( basename $0 ).${date}
	array_options="--array ${array_file} "
	
	threads=4

	while [ $# -gt 0 ] ; do
		case $1 in
			-t|--threads)
				shift; threads=$1; shift;;
			-o|--out|--outdir|-e|--extension|-r|--ref)
				array_options="${array_options} $1 $2"
				shift; shift;;
			-h|--help)
				echo
				echo $0 --ref /PATH/TO/ref_genome path/*1.fastq.gz
				echo
				exit;;
			-*)
				array_options="${array_options} $1"
				shift;;
			*)
				realpath --no-symlinks $1 >> ${array_file}
				shift;;
		esac
	done

	# using M so can be more precise-ish
	mem=$[threads*7500]M
	scratch_size=$[threads*28]G	#	not always necessary

	max=$( cat ${array_file} | wc -l )

	mkdir -p ${PWD}/logs

	array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%4 \
		--parsable --job-name="$(basename $0)" \
		--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
		--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
			$( realpath ${0} ) ${array_options} )

	echo "Throttle with ..."
	echo "scontrol update ArrayTaskThrottle=8 JobId=${array_id}"

fi

