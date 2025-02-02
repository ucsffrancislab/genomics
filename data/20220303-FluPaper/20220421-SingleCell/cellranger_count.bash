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

#--fastqs /francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR13194367/B1-c1-10X_L001_R1_001.fastq.gz /francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR13194367/B1-c1-10X_L001_R2_001.fastq.gz \
#If your files came from bcl2fastq or mkfastq:
# - Make sure you are specifying the correct --sample(s), i.e. matching the sample sheet
# - Make sure your files follow the correct naming convention, e.g. SampleName_S1_L001_R1_001.fastq.gz (and the R2 version)
# - Make sure your --fastqs points to the correct location.
#
#Refer to the "Specifying Input FASTQs" page at https:

# 1159  ln -s B1-c1-10X_L001_R1_001.fastq.gz B1-c1-10X_S0_L001_R1_001.fastq.gz
# 1160  ln -s B1-c1-10X_L001_R2_001.fastq.gz B1-c1-10X_S0_L001_R2_001.fastq.gz

#--transcriptome /francislab/data1/raw/20220303-FluPaper/hg38_iav \

#--transcriptome /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/hg38 \

s="B1-c1"

cellranger count \
--id ${s} \
--sample ${s}-10X \
--fastqs /francislab/data2/working/20220303-FluPaper/20220421-SingleCell/fastq \
--transcriptome /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/hg38_iav \
--localcores 16 \
--localmem 120 \
--localvmem 120


#cellranger mkref --genome=hg38_iav \
#--fasta=/francislab/data1/raw/20220303-FluPaper/hg38_iav.fa \
#--genes=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
#--nthreads=32 --memgb=240

