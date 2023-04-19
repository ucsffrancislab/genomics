#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date


#	https://github.com/bergmanlab/ngs_te_mapper2

if [ $# -gt 0 ] ; then

	#set -e  #       exit if any command fails
	set -u  #       Error on usage of unset variables
	set -o pipefail
	if [ -n "$( declare -F module )" ] ; then
		echo "Loading required modules"
		module load CBI samtools bwa bedtools2
		#module load CBI samtools/1.13 bwa bedtools2
		#	bowtie2/2.4.4 htslib bedtools2/2.30.0
	fi

	#	Needs RepeatMasker, samtools, bwa, bedtools2, seqtk

	echo "Running"

	export PATH="${PATH}:${HOME}/.local/RepeatMasker/"

	ngs_te_mapper2 $*

else

	threads=32

	sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL \
		--time=20160 --nodes=1 --ntasks=${threads} --mem=240G \
		--output=${PWD}/ngs_te_mapper2.log \
			${PWD}/ngs_te_mapper2.bash -t ${threads} \
			-f ${PWD}/out/02-2483-01A-01D-1494_R1.fastq.gz,${PWD}/out/02-2483-01A-01D-1494_R2.fastq.gz \
			-l /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/D_mel_transposon_sequence_set_v10.1.fa \
			-r /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa 

fi


