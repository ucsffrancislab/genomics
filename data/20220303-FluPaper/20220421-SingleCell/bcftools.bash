#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI bcftools
fi
set -x	#	print expanded command before executing it



#	grep -m 1 B1_c1 /francislab/data1/raw/20220303-FluPaper/inputs/2_calculate_residuals_and_DE_analyses/individual_meta_data_for_GE_with_scaledCovars_with_CTC.txt | awk -F, '{print $2}'
#HMN83551

#	ls -1 /francislab/data1/raw/20220303-FluPaper/PRJNA736483/*/HMN83551_alignment_bam.bam
#	/francislab/data1/raw/20220303-FluPaper/PRJNA736483/SRR14773640/HMN83551_alignment_bam.bam

#	bcftools mpileup --output-type u --fasta-ref $fasta_ref $f | \
#	bcftools call  --output-type z --output $b.call.vcf.gz \
#		--multiallelic-caller --variants-only && \
#	bcftools index $b.call.vcf.gz && \

b=/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/HMN83551

bcftools mpileup --output-type u --fasta-ref /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/GCA_000001405.14_GRCh37.p13_genomic-select.fa /francislab/data1/raw/20220303-FluPaper/PRJNA736483/SRR14773640/HMN83551_alignment_bam.bam | bcftools call  --output-type z --output $b.call.vcf.gz --multiallelic-caller --variants-only 

bcftools index $b.call.vcf.gz


