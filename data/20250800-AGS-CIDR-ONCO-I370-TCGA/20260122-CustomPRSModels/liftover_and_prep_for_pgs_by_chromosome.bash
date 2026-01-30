#!/usr/bin/env bash

data=$1	#	cidr,tcga,i370,onco
c=$2	#	chromosome

set -x
set -e	#	exit if any command fails	#	the liftover command technically fails
set -u	#	Error on usage of unset variables
set -o pipefail


threads=${SLURM_NTASKS:-4}
memory=${SLURM_MEM_PER_NODE:-10000}

#module load bcftools 	#	don't use the module. use my install which includes the liftover plugin
module load plink2 htslib

indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas

outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

#	csi is the preferred, more modern, index and supports larger
#	tbi is more compatible, but I haven't found any issues yet

#	vcf files need indexing before concatenating


vcf=${indir}/imputed-umich-${data}/chr${c}.dose.vcf.gz

outdir=$( dirname ${vcf} )/hg38
mkdir -p ${outdir}

annotated=${outdir}/annotated.$( basename ${vcf} )
if [ -f ${annotated} ] ; then
	echo "Annotated exists. Skipping."
else
	bcftools annotate \
		--rename-chrs <(echo -e "${c}\tchr${c}") \
		-Oz -o ${annotated} \
		--write-index=csi \
		${vcf} 
fi

lifted=${outdir}/lifted.$( basename ${vcf} )
if [ -f ${lifted} ] ; then
	echo "Lifted exists. Skipping."
else
	#	NEEDS A PLUGIN
	#	bcftools plugin <name> [OPTIONS] <file> [-- PLUGIN_OPTIONS]
	#	use local bcftools with plugin
	#	module unload bcftools
	bcftools +liftover --threads ${threads} -O u \
		${annotated} \
		-- \
		--src-fasta-ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.fa.gz \
		--chain /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz \
		--fasta-ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz \
		--reject ${outdir}/rejected.$( basename ${vcf} ) \
		| bcftools sort -Oz -o ${lifted}
fi

norm=${outdir}/norm.$( basename ${vcf} )
if [ -f ${norm} ] ; then
	echo "Normalized exists. Skipping."
else
	bcftools norm -Oz -o ${norm} \
		--check-ref x -m -any \
		-f /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz \
		${lifted} 
fi

final=${outdir}/final.$( basename ${vcf} )
if [ -f ${for_pgs} ] ; then
	echo "final exists. Skipping."
else
	bcftools annotate --threads ${threads} --set-id '%CHROM:%POS:%REF:%ALT' -O u ${norm} | \
		bcftools view -m2 -M2 -v snps -Oz --write-index=csi -o ${final}
fi


echo "Done"
date
echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"


