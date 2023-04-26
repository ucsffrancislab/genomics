#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it

if [ $( basename ${0} ) == "slurm_script" ] ; then
#if [ -n "${SLURM_JOB_NAME}" ] ; then
	script=${SLURM_JOB_NAME}
else
	script=$( basename $0 )
fi

#	PWD preserved by slurm for where job is run? I guess so.
arguments_file=${PWD}/${script}.arguments

threads=${SLURM_NTASKS:-4}
extension="_R1.fastq.gz"
#IN="${PWD}/in"
#OUT="${PWD}/out"

while [ $# -gt 0 ] ; do
	case $1 in
		-i|--in)
			shift; IN=$1; shift;;
		-t|--threads)
			shift; threads=$1; shift;;
		-o|--out)
			shift; OUT=$1; shift;;
#		-l|--transposon)
#			shift; transposon_fasta=$1; shift;;
#		-r|--human)
#			shift; human_fasta=$1; shift;;
		-e|--extension)
			shift; extension=$1; shift;;
		-h|--help)
			echo
			echo "Good question"
			echo
			exit;;
		*)
			echo "Unknown params :${1}:"; exit ;;
	esac
done

mem=$[threads*7]
scratch_size=$[threads*28]

#if [ -n "${SLURM_ARRAY_TASK_ID}" ] ; then
#if [ $( basename ${0} ) == "slurm_script" ] ; then
if [ $( basename ${0} ) == "slurm_script" ] ; then

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools star/2.7.7a
	fi
	
	date
	
	#		#IN="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/in"
	#		OUT="/francislab/data1/working/20230217_costello_LG3_exomes_recal/20230303-MELT/out"
	#		
	#		#while [ $# -gt 0 ] ; do
	#		#	case $1 in
	#		#		-d|--dir)
	#		#			shift; OUT=$1; shift;;
	#		#		*)
	#		#			echo "Unknown params :${1}:"; exit ;;
	#		#	esac
	#		#done

	mkdir -p ${OUT}

	line_number=${SLURM_ARRAY_TASK_ID:-1}
	echo "Running line_number :${line_number}:"

	#	Use a 1 based index since there is no line 0.

	line=$( sed -n "$line_number"p ${arguments_file} )
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

	set -x

	outFileNamePrefix="${OUT}/${base}."

	f="${outFileNamePrefix}Aligned.sortedByCoord.out.bam"
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Running STAR"
#		set -x  #       print expanded command before executing it
		STAR_scratch.bash \
			--runMode alignReads \
			--runThreadN ${threads} \
			--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a \
			--readFilesType Fastx \
			--readFilesIn ${R1} ${R2} \
			--readFilesCommand zcat \
			--outSAMstrandField intronMotif \
			--outSAMattributes Standard XS \
			--outSAMtype BAM SortedByCoordinate \
			--outFileNamePrefix ${outFileNamePrefix}

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

	ls -1 ${IN}/*${extension} > ${arguments_file}

	max=$( cat ${arguments_file} | wc -l )

	mkdir -p ${PWD}/logs
	date=$( date "+%Y%m%d%H%M%S%N" )

	array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-${max}%10 \
		--parsable --job-name="$(basename $0)" \
		--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem}G --gres=scratch:${scratch_size}G \
		--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
			$( realpath ${0} ) --threads ${threads} --out ${OUT} --extension ${extension} )


	echo "Throttle with ..."
	echo "scontrol update ArrayTaskThrottle=8 JobId=${array_id}"

fi

#	STAR_array_wrapper.bash --threads 16 \
#	--in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200612-prepare/trimmed/length \
#	--out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-STAR_hg38_strand/out \




