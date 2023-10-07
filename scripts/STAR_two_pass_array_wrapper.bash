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

	echo $*

	squeue --me

	env

	sleep 1

#		### Step 1: Building the STAR index.*
#		
#		STAR
#		--runMode genomeGenerate
#		--genomeDir <star_index_path>
#		--genomeFastaFiles <reference>
#		--sjdbOverhang 100
#		--sjdbGTFfile <gencode.v36.annotation.gtf>
#		--runThreadN 8

	step=$1
	shift
	echo "Step:${step}"

	if [ "${step}" == "1st_pass" ] ; then

		echo "### Step 2: Alignment 1st Pass."

#		STAR
#		--genomeDir <star_index_path>
#		--readFilesIn <fastq_left_1>,<fastq_left2>,... <fastq_right_1>,<fastq_right_2>,...
#		--runThreadN <runThreadN>
#		--outFilterMultimapScoreRange 1
#		--outFilterMultimapNmax 20
#		--outFilterMismatchNmax 10
#		--alignIntronMax 500000
#		--alignMatesGapMax 1000000
#		--sjdbScore 2
#		--alignSJDBoverhangMin 1
#		--genomeLoad NoSharedMemory
#		--readFilesCommand <bzcat|cat|zcat>
#		--outFilterMatchNminOverLread 0.33
#		--outFilterScoreMinOverLread 0.33
#		--sjdbOverhang 100
#		--outSAMstrandField intronMotif
#		--outSAMtype None
#		--outSAMmode None

	elif [ "${step}" == "regenome" ] ; then

		echo "### Step 3: Intermediate Index Generation."

#		STAR
#		--runMode genomeGenerate
#		--genomeDir <output_path>
#		--genomeFastaFiles <reference>
#		--sjdbOverhang 100
#		--runThreadN <runThreadN>
#		--sjdbFileChrStartEnd <SJ.out.tab from previous step>

	elif [ "${step}" == "2nd_pass" ] ; then

		echo "### Step 4: Alignment 2nd Pass."

#		STAR
#		--genomeDir <output_path from previous step>
#		--readFilesIn <fastq_left_1>,<fastq_left2>,... <fastq_right_1>,<fastq_right_2>,...
#		--runThreadN <runThreadN>
#		--outFilterMultimapScoreRange 1
#		--outFilterMultimapNmax 20
#		--outFilterMismatchNmax 10
#		--alignIntronMax 500000
#		--alignMatesGapMax 1000000
#		--sjdbScore 2
#		--alignSJDBoverhangMin 1
#		--genomeLoad NoSharedMemory
#		--limitBAMsortRAM 0
#		--readFilesCommand <bzcat|cat|zcat>
#		--outFilterMatchNminOverLread 0.33
#		--outFilterScoreMinOverLread 0.33
#		--sjdbOverhang 100
#		--outSAMstrandField intronMotif
#		--outSAMattributes NH HI NM MD AS XS
#		--outSAMunmapped Within
#		--outSAMtype BAM SortedByCoordinate
#		--outSAMheaderHD @HD VN:1.4
#		--outSAMattrRGline <formatted RG line provided by wrapper>

	else

		echo "Unknown step"


	fi

else

	mkdir -p ${PWD}/logs/

#	step1_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-10%2 \
#		--parsable --job-name="1-$(basename $0)" \
#		--time=1-0 --nodes=1 --ntasks=1 --mem=1G \
#		--output=${PWD}/logs/$(basename $0).step1.$( date "+%Y%m%d%H%M%S%N" )-%A_%a.out.log \
#				$( realpath ${0} ) 1st_pass )
#
#	step2_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
#	  --dependency=${step1_id} \
#		--parsable --job-name="2-$(basename $0)" \
#		--time=1-0 --nodes=1 --ntasks=1 --mem=1G \
#		--output=${PWD}/logs/$(basename $0).step2.out.log \
#				$( realpath ${0} ) regenome )
#
#	step3_id=$( sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-10%2 \
#	  --dependency=${step2_id} \
#		--parsable --job-name="3-$(basename $0)" \
#		--time=1-0 --nodes=1 --ntasks=1 --mem=1G \
#		--output=${PWD}/logs/$(basename $0).step3.$( date "+%Y%m%d%H%M%S%N" )-%A_%a.out.log \
#				$( realpath ${0} ) 2nd_pass )

fi


