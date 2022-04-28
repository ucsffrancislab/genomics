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
#	module load CBI cellranger/4.0.0 # htslib samtools bowtie2
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

##cellranger count \
#--id B1-c1 \
#--sample B1-c1-10X \
#--fastqs /francislab/data1/raw/20220303-FluPaper/PRJNA682434/SRR13194367/ \
#--transcriptome /francislab/data1/raw/20220303-FluPaper/hg38_iav \
#--localcores 16 \
#--localmem 120 \
#--localvmem 120


#cellranger mkref --genome=hg38_iav \
#--fasta=/francislab/data1/raw/20220303-FluPaper/hg38_iav.fa \
#--genes=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
#--nthreads=32 --memgb=240

#B1-c1/outs/filtered_feature_bc_matrix/barcodes.tsv.gz
#B1-c1/outs/raw_feature_bc_matrix/barcodes.tsv.gz
#	--barcodes /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/B1-c1/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
#	--barcodes /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/B1-c1/outs/raw_feature_bc_matrix/barcodes.tsv.gz \

#	--fasta /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa \

s="B1-c1"

singularity exec --bind /francislab /francislab/data1/refs/singularity/souporcell_latest.sif souporcell_pipeline.py \
	--bam /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/out/${s}/outs/possorted_genome_bam.bam \
	--fasta /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/hg38_iav.fa \
	--barcodes /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/out/${s}/outs/filtered_feature_bc_matrix/barcodes.tsv.gz \
	--common_variants /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/common_variants_grch38.vcf \
	--threads 16 \
	--out_dir /francislab/data1/working/20220303-FluPaper/20220421-SingleCell/out/${s}/souporcell \
	--skip_remap True \
	--clusters 6


#	--skip_remap True \
#	kinda curious what remapping will produce. looks like it leaves quite a few fq files


#	trying again with full sample of all 4 L00?	 WORKED!?!?!?!
#	--no_umi True \

#	no_umi needed or no results at all followed by crash
#	I'm pretty sure that there are UMIs though.


