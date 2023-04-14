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

	sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --output=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/ngs_te_mapper2.log --time=1440 --nodes=1 --ntasks=16 --mem=120G /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/ngs_te_mapper2.bash -f /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R1.fastq.gz,/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/02-0047-01A-01R-1849-01+1_R2.fastq.gz -l /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/D_mel_transposon_sequence_set_v10.1.fa -r /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa -t 16

fi


