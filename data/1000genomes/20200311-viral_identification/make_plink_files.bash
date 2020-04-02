#!/usr/bin/env bash



#	The first two columns of the files are the Family ID ( FID ) and the Sample ID ( IID ) followed by the Phenotype. For the case that the Family ID is unknown use the Sample ID.
#
#	FID
#	IID
#	--keep accepts a space/tab-delimited text file with family IDs in the first column and within-family IDs in the second column, and removes all unlisted samples from the current analysis. --remove does the same for all listed samples.
#	--extract normally accepts a text file with a list of variant IDs (usually one per line, but it's okay for them to just be separated by spaces), and removes all unlisted variants from the current analysis.
#
#	--update-sex expects a file with FIDs and IIDs in the first two columns, and sex information (1 or M = male, 2 or F = female, 0 = missing) in the (n+2)th column. If no second parameter is provided, n defaults to 1. It is frequently useful to set n=3, since sex defaults to the 5th column in .ped and .fam files.
#
#
#
#	1=male, 2=female, 0=unknown
#
#
#	awk -F"\t" -vOFS="\t" '($6=="EUR"){s=($3=="male")?1:2;print $2,$1,s}' /francislab/data1/raw/1000genomes/metadata.tsv > EUR_IDS.txt


#	--extract's file expects a variant ID, but all in this list don't have ids
#plink "--extract range [filename]" can do this.
#
#The input file is expected to have chromosome IDs in the first column, [first bp, last bp] (ok for these values to be identical) in the second and third columns, and arbitrary range IDs in the fourth column.
#
#	zcat UKB_GWAS_MAF01_INFO30.list.gz | awk -vOFS="\t" '(!/^#/){print $1,$2,$2}' | head



#outdir=/francislab/data1/working/1000genomes/20200311-viral_identification/select_eur_all
#mkdir -p "${outdir}"
#
#for vcf in /francislab/data1/raw/1000genomes/release/20130502/ALL.chr*vcf.gz ; do
#	echo $vcf
#	base=$( basename $vcf )
#	base=${base%.phase3*}
#	base=${base#ALL.}
#	echo $base
#
##  	--extract UKB_GWAS_MAF01_INFO30.list.gz \
#
#	plink --make-bed \
#  	--keep EUR_IDS.txt \
#  	--update-sex EUR_IDS.txt \
#  	--vcf "${vcf}" \
#  	--out "${outdir}/${base}"
#
#done



#outdir=/francislab/data1/working/1000genomes/20200311-viral_identification/select_eur_UKB
#mkdir -p "${outdir}"
#
#for vcf in /francislab/data1/raw/1000genomes/release/20130502/ALL.chr*vcf.gz ; do
#	echo $vcf
#	base=$( basename $vcf )
#	base=${base%.phase3*}
#	base=${base#ALL.}
#	echo $base
#
#	plink --make-bed \
#  	--extract UKB_GWAS_MAF01_INFO30.list.gz \
#  	--keep EUR_IDS.txt \
#  	--update-sex EUR_IDS.txt \
#  	--vcf "${vcf}" \
#  	--out "${outdir}/${base}"
#
#done



outdir=/francislab/data1/working/1000genomes/20200311-viral_identification/select_eur_positions
mkdir -p "${outdir}"

for vcf in /francislab/data1/raw/1000genomes/release/20130502/ALL.chr*vcf.gz ; do
	echo $vcf
	base=$( basename $vcf )
	base=${base%.phase3*}
	base=${base#ALL.}
	echo $base

	plink --make-bed \
  	--extract range extract_range.txt \
  	--keep EUR_IDS.txt \
  	--update-sex EUR_IDS.txt \
  	--vcf "${vcf}" \
  	--out "${outdir}/${base}"

done



