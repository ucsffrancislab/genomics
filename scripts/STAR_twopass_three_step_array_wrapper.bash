#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
#set -x  #       print expanded command before executing it

#	Based on 
#	https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/Expression_mRNA_Pipeline/#rna-seq-alignment-command-line-parameters

function usage(){
	set +x
	echo
	echo "Usage:"
	echo
	echo $0 --ref /PATH/TO/ref_genome.fa path/*1.fastq.gz
	echo
	echo $0 --threads 8 --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230424-STAR_hg38_strand/out 
	echo --ref /PATH/TO/ref_genome path/*1.fastq.gz
	echo
	echo "Note that the reference needs to also have a '.fa' present as well"
	echo
	exit
}

ARGS=$*

trap "{ chmod -R a+w $TMPDIR ; }" EXIT

if [ $( basename ${0} ) == "slurm_script" ] ; then

	echo "Running an individual array job"

	threads=${SLURM_NTASKS:-4}
	echo "threads :${threads}:"
	mem=${SLURM_MEM_PER_NODE:-30000M}
	echo "mem :${mem}:"

	extension="_R1.fastq.gz"
	#ref=/francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a
	ref=/francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome

	#	MUST BE FIRST
	step=$1
	shift
	echo "Step:${step}"

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
		module load CBI samtools star
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
	echo "R1 : $R1"
	echo "R2 : $R2"
	#echo "bam : $bam"
	echo 

	date=$( date "+%Y%m%d%H%M%S%N" )


	echo "Running"

	set -x  #       print expanded command before executing it

#		### Step 1: Building the STAR index.* - DONE BEFORE RUN
#		
#		STAR
#		--runMode genomeGenerate
#		--genomeDir <star_index_path>
#		--genomeFastaFiles <reference>
#		--sjdbOverhang 100
#		--sjdbGTFfile <gencode.v36.annotation.gtf>
#		--runThreadN 8

	if [ "${step}" == "1st_pass" ] ; then

		echo "### Step 2: Alignment 1st Pass."

		mkdir -p ${OUT}/1stPass
		outFileNamePrefix="${OUT}/1stPass/${base}."

		f="${outFileNamePrefix}SJ.out.tab"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			STAR \
				--genomeDir ${ref} \
				--readFilesIn ${R1} ${R2} \
				--runThreadN ${threads} \
				--outFilterMultimapScoreRange 1 \
				--outFilterMultimapNmax 20 \
				--outFilterMismatchNmax 10 \
				--alignIntronMax 500000 \
				--alignMatesGapMax 1000000 \
				--sjdbScore 2 \
				--alignSJDBoverhangMin 1 \
				--genomeLoad NoSharedMemory \
				--outFilterMatchNminOverLread 0.33 \
				--outFilterScoreMinOverLread 0.33 \
				--sjdbOverhang 100 \
				--outSAMstrandField intronMotif \
				--runMode alignReads \
				--readFilesType Fastx \
				--readFilesCommand zcat \
				--outFileNamePrefix ${outFileNamePrefix} \
				--outSAMtype None \
				--outSAMmode None

				#--outSAMtype None \
				#--outSAMmode None \

				#--outSAMattributes NH HI NM MD AS XS \
				#--outSAMtype BAM SortedByCoordinate \
				#--outSAMheaderHD @HD VN:1.4 \
				#--outSAMattrRGline ID:${base} SM:${base} \
				#--outSAMunmapped Within KeepPairs \
				#--outBAMsortingBinsN $[900/threads] \
				#--limitBAMsortRAM $[SLURM_NTASKS*7000000000]

			chmod a-w ${f}

		fi

	elif [ "${step}" == "regenome" ] ; then

		echo "### Step 3: Intermediate Index Generation."

		#	20230628-Costello/20231016-STAR_two_pass
		#	Fatal LIMIT error: the number of junctions to be inserted on the fly =4973683 is larger than the limitSjdbInsertNsj=1000000
		#	Fatal LIMIT error: the number of junctions to be inserted on the fly =4973683 is larger than the limitSjdbInsertNsj=1000000
		#	SOLUTION: re-run with at least --limitSjdbInsertNsj 4973683

		STAR \
			--runMode genomeGenerate \
			--genomeDir ${PWD}/genome \
			--genomeFastaFiles ${ref}.fa \
			--sjdbOverhang 100 \
			--limitSjdbInsertNsj 10000000 \
			--runThreadN ${threads} \
			--sjdbFileChrStartEnd ${OUT}/1stPass/*.SJ.out.tab

	elif [ "${step}" == "2nd_pass" ] ; then

		echo "### Step 4: Alignment 2nd Pass."

		outFileNamePrefix="${OUT}/${base}."

		f="${outFileNamePrefix}Aligned.sortedByCoord.out.bam"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"

			STAR \
				--genomeDir ${PWD}/genome \
				--readFilesIn ${R1} ${R2}  \
				--runThreadN ${threads} \
				--outFilterMultimapScoreRange 1 \
				--outFilterMultimapNmax 20 \
				--outFilterMismatchNmax 10 \
				--alignIntronMax 500000 \
				--alignMatesGapMax 1000000 \
				--sjdbScore 2 \
				--alignSJDBoverhangMin 1 \
				--genomeLoad NoSharedMemory \
				--outFilterMatchNminOverLread 0.33 \
				--outFilterScoreMinOverLread 0.33 \
				--sjdbOverhang 100 \
				--outSAMstrandField intronMotif \
				--outSAMattributes NH HI NM MD AS XS \
				--outSAMtype BAM SortedByCoordinate \
				--outSAMheaderHD @HD VN:1.4 \
				--outSAMattrRGline ID:${base} SM:${base} \
				--outSAMunmapped Within KeepPairs \
				--runMode alignReads \
				--readFilesType Fastx \
				--readFilesCommand zcat \
				--outFileNamePrefix ${outFileNamePrefix} \
				--outBAMsortingBinsN $[900/threads] \
				--limitBAMsortRAM $[SLURM_NTASKS*7000000000]

			chmod a-w $f
			samtools index $f
			chmod a-w ${f}.bai

		fi

	else

		echo "Unknown step"

	fi

	echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"

else

	mkdir -p ${PWD}/logs/

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

		#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
		#	"hours:minutes:sec‐onds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".

		step1_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%4 \
			--parsable --job-name="1-$(basename $0)" \
			--time=14-0 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
			--output=${PWD}/logs/$(basename $0).1stPass.$( date "+%Y%m%d%H%M%S%N" )-%A_%a.out.log \
					$( realpath ${0} ) 1st_pass ${array_options} )

		step2_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		  --dependency=afterok:${step1_id} \
			--parsable --job-name="2-$(basename $0)" \
			--time=14-0 --nodes=1 --ntasks=64 --mem=495G --gres=scratch:2000G \
			--output=${PWD}/logs/$(basename $0).ReGenome.$( date "+%Y%m%d%H%M%S%N" ).out.log \
					$( realpath ${0} ) regenome ${array_options} )

		step3_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=${array}%4 \
		  --dependency=afterok:${step2_id} \
			--parsable --job-name="3-$(basename $0)" \
			--time=14-0 --nodes=1 --ntasks=${threads} --mem=${mem} --gres=scratch:${scratch_size} \
			--output=${PWD}/logs/$(basename $0).2ndPass.$( date "+%Y%m%d%H%M%S%N" )-%A_%a.out.log \
					$( realpath ${0} ) 2nd_pass ${array_options} )

		echo "Throttle with ..."
		echo "scontrol update JobId=${step1_id} ArrayTaskThrottle=8"

	else

		echo "No files given"
		usage

	fi

fi

