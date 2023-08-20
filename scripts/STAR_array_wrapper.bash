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
	echo $0 --ref /PATH/TO/ref_genome.fa path/*1.fastq.gz
	echo
	echo $0 --threads 8 --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-STAR_hg38_strand/out 
	echo --ref /PATH/TO/ref_genome.fa path/*1.fastq.gz
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
	#ref=/francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a
	ref=/francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; shift;;
			-r|--ref)
				shift; ref=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done

	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools star	#/2.7.7a
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
			--outSAMattrRGline ID:${base} SM:${base} \
			--outSAMunmapped Within KeepPairs \
			--outFileNamePrefix ${outFileNamePrefix} \
			--outBAMsortingBinsN $[900/threads] \
			--limitBAMsortRAM $[SLURM_NTASKS*7000000000]

#			--outBAMsortingBinsN 10 \
#			--limitBAMsortRAM $[SLURM_NTASKS*7000000000] \



#	out/26-5134-01A-01R-1850-01+1._STARtmp//BAMsort
#	contains 1 for each thread. Each folder then contains about 50 files (--outBAMsortingBinsN default is 50)
#	That is 800 files which is fine
#	More threads, say 32 would try to create 1600 files but crashes just over 1000. Probably a ulimit thing
#	So, if using 32 threads. Would need to set the bins to 25?
#	64 set to 12
#	10 with 32 worked with the addition of setting sortRAM


#			--outBAMsortingBinsN 10 \
#\
#			--limitBAMsortRAM $[SLURM_NTASKS*7000000000]

			#--outBAMsortingBinsN 100 \
#	Too small and 8/60 will run out of memory, which is odd since 60 > 39
#	EXITING because of fatal ERROR: not enough memory for BAM sorting: 
#	SOLUTION: re-run STAR with at least --limitBAMsortRAM 39895949651
#
#	Too large and I think that you create too many files.
#	BAMoutput.cpp:27:BAMoutput: exiting because of *OUTPUT FILE* error: could not create output file /scratch/gwendt/1468442/outdir/02-2483-01A-01R-1849-01+2._STARtmp//BAMsort/5/16
#	SOLUTION: check that the path exists and you have write permission for this file. Also check ulimit -n and increase it to allow more open files.

#	outBAMsortingBinsN      50
#	    int: >0:  number of genome bins fo coordinate-sorting


		#	The XS flag is assigned only for spliced reads based on the intron motif of the junction.
		#	For an unstranded library, the read may be sequenced from the 1st cDNA strand (opposite to RNA),
		#	but the intron motif allows to determine the actual RNA strand.

		#samtools index ${f}
		#chmod -w ${f}.bai

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
	array_options="--array_file ${array_file} "
	
	threads=4
	array=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array)
				shift; array=$1; shift;;
			-t|--threads)
				shift; threads=$1; shift;;
			-o|--out|--outdir|-e|--extension|-r|--ref)
				array_options="${array_options} $1 $2"; shift; shift;;
			-h|--help)
				usage;;
#			-*)
#				array_options="${array_options} $1"; shift;;
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

		set -x  #       print expanded command before executing it

		[ -z "${array}" ] && array="1-${max}"

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
			--parsable --job-name="$(basename $0)" \
			--time=10080 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )

		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

