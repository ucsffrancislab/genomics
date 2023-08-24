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
	echo $0 --threads 4
	echo --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out
	echo --extension .STAR.hg38.Aligned.out.bam
	echo /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out/*.STAR.hg38.Aligned.out.bam
	echo
	exit
}


if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SLURM_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	TEPROF2=/c4/home/gwendt/github/twlab/TEProf2Paper/bin
	ARGUMENTS=/francislab/data1/refs/TEProf2/TEProF2.arguments.txt
	extension="_R1.fastq.gz"
	strand=""

	while [ $# -gt 0 ] ; do
		case $1 in
			--array_file)
				shift; array_file=$1; shift;;
			-o|--out)
				shift; OUT=$1; shift;;
			-e|--extension)
				shift; extension=$1; shift;;
			-s|--strand)
				shift; strand=$1; shift;;
				#	I really don't know which is correct
				# --rf assume stranded library fr-firststrand
				# --fr assume stranded library fr-secondstrand - guessing this is correct, but its a guess
				#	5' ------------------------------> 3'
				#	   /2 ----->            <----- /1 - fr-firststrand
				#	   /1 ----->            <----- /2 - fr-secondstrand
				#	unstranded
				#	second-strand = directional, where the first read of the read pair (or in case of single end reads, the only read) is from the transcript strand
				#	first-strand = directional, where the first read (or the only read in case of SE) is from the opposite strand.
			*)
				echo "Unknown param :${1}:"; usage ;;
		esac
	done
	
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools bwa bedtools2 cufflinks star/2.7.7a
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
	bam=${line}
	#R1=${line}
	#R2=${line/_R1./_R2.}

	echo
	echo "base : ${base}"
	echo "ext : ${extension}"
	#echo "r1 : $R1"
	#echo "r2 : $R2"
	echo "bam : $bam"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )

	echo "Running"

	set -x



	#	QC: Using software such as FASTQC

	#	Adapter Trimming

	#	Alignment: We normally user and prefer STAR. Make sure that the -XS tag will be outputted since the splice-aware assembly software such as stringtie has the information it needs. HISAT2 can also be used, but HISAT uses 60 instead of 255 for uniquelly mapped reads which will interfere with code in future steps.
	#	Note: Future steps require sorted and indexed bam files. Thus, outputting sorted BAM files will be beneficial.
	#	Sorting and Indexing: The BAM files need to be sorted by position (samtools sort) and need to be indexed (samtools index)
	#	Pretty sure that STAR will produce sorted bam with index

	#	Filtering: Due to problems with mapping to repetitive elements, we usually will filter to only include uniquelly mapped reads.

	outbase=${OUT}/${base}
	f=${outbase}.unique.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Selecting only uniquely mapped reads"

		samtools view -h -q 250 ${bam} | samtools sort --threads $[threads-1] -o ${f} -
		samtools index ${f}
		chmod -w ${f} ${f}.bai
	fi

#	samtools view -q 255 -h EGAR00001163970_636782_1_1.rnaseq.fastqAligned.sortedByCoord.out.bam | stringtie - -o EGAR00001163970_636782_1_1.rnaseq.fastqAligned.sortedByCoord.out.gtf -m 100 -c 1


	#	Op BAM Description Consumes query Consumes reference
	#	M 0 alignment match (can be a sequence match or mismatch) yes yes
	#	I 1 insertion to the reference yes no
	#	D 2 deletion from the reference no yes
	#	N 3 skipped region from the reference no yes
	#	S 4 soft clipping (clipped sequences present in SEQ) yes no
	#	H 5 hard clipping (clipped sequences NOT present in SEQ) no no
	#	P 6 padding (silent deletion from padded reference) no no
	#	= 7 sequence match yes yes
	#	X 8 sequence mismatch yes yes



	#	Assembly: STRINGTIE Default parameters will work if unstranded, but you should look at stringtie documentation to adjust paramaters based on type of sequencing run. For discovering low coverage transcripts we sometimes set the following flags (-c 1 -m 100). Note, future steps will require being able to map the gtf file to the bam file, so the easiest way to do this would be to just change the extension of the files from *.bam to *.gtf (test1.bam to test1.gtf).

	date

	infile=${f}
	outbase=${OUT}/${base}
	f=${outbase}.unique.gtf
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#echo "Stringtie : ASSUMING --rf IS CORRECT. WITHOUT IT, NOTHING GETS ANNOTATED."

		echo stringtie ${infile} -p ${threads} -o ${f} -m 100 -c 1 ${strand}
		stringtie ${infile} -p ${threads} -o ${f} -m 100 -c 1 ${strand}

		chmod -w ${f}
	fi

	date



	#	Not sure if these annotated files are really needed.



	#(1) <gtffile>_annotated_test_all
	#(2) <gtffile>_annotated_filtered_test_all
	#(3) <gtffile>_annotated_test*
	#(4) <gtffile>_annotated_filtered_test*

	infile=${f}
	outbase=${OUT}/${base}
	f=${outbase}.unique.gtf_annotated_test_all
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "(1/8) Annotate GTF Files"
		echo "rmskhg38_annotate_gtf_update_test_tpm"

		${TEPROF2}/rmskhg38_annotate_gtf_update_test_tpm.py ${infile} ${ARGUMENTS}

		chmod -w ${f}
	fi

	date

	outbase=${OUT}/${base}
	#for s in annotated_filtered_test_all annotated_test_all ; do
	for s in annotated_filtered_test_all ; do

		#(1) <gtffile>annotated_filtered_test(all)_c

		f=${outbase}.unique.gtf_${s}_c
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "(2/8) Annotate GTF Files"
			echo "annotationtpmprocess.py filtered"

			${TEPROF2}/annotationtpmprocess.py ${infile}_${s}

			chmod -w ${f}
		fi

	done

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
			-o|--out|--outdir|-e|--extension|-s|--strand)
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

		#	ls -1 ${IN}/*${extension} > ${array_file}

		max=$( cat ${array_file} | wc -l )

		mkdir -p ${PWD}/logs
		#	date=$( date "+%Y%m%d%H%M%S%N" )

		set -x  #       print expanded command before executing it
		#	strand_option=""
		#	[ -n "${strand}" ] && strand_option="--strand ${strand}"
		[ -z "${array}" ] && array="1-${max}"

		#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
		#	"hours:minutes:sec‐onds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".

		array_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%1 \
			--parsable --job-name="$(basename $0)" \
			--time=14-0 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
			--output=${PWD}/logs/$(basename $0).${date}-%A_%a.out.log \
				$( realpath ${0} ) ${array_options} )

		echo "Throttle with ..."
		echo "scontrol update JobId=${array_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

