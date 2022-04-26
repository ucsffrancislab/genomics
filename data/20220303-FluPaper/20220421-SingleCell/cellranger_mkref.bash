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
	module load CBI cellranger/4.0.0 # htslib samtools bowtie2
fi
set -x	#	print expanded command before executing it



#--fasta=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/2/FJ966080.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/3/FJ966081.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/3/JF915188.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/4/FJ966082.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/4/GQ280797.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/4/JF915184.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/4/KP406524.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/5/FJ966083.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/6/FJ966084.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/6/KP406527.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/7/FJ966085.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/7/FJ969513.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/8/FJ966086.1.fa \
#--fasta=/francislab/data1/raw/20220303-FluPaper/Influenza_A_virus_A_California_04_2009_H1N1/8/FJ969514.1.fa \

#cellranger mkref --genome=hg38 \
#--fasta=/francislab/data1/raw/20220303-FluPaper/hg38_iav.fa \
#--fasta=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \
#--genes=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \

cellranger mkref --genome=hg38_iav --nthreads=16 --memgb=120 \
--fasta=/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/hg38_iav.fa \
--genes=/francislab/data2/working/20220303-FluPaper/20220421-SingleCell/hg38.ncbiRefSeq.iav.gtf

