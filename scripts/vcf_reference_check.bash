#!/usr/bin/env bash

module load samtools bcftools


#	cmd="samtools faidx /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa chr"$1":"$2"-"$2" | tail -1"

vcf=$1
reference=$2

	#cmd="samtools faidx "reference" chr"$1":"$2"-"$2" | tail -1"

bcftools view -H $vcf | awk -v reference=$reference 'BEGIN{FS=OFS="\t"}{

	cmd="samtools faidx "reference" "$1":"$2"-"$2" | tail -1"
	cmd | getline ref
	close(cmd)

	count++

	#print $1,$2,$4,ref
	if ( toupper($4) != toupper(ref) ){
		diff++
		print $1,$2,$4,ref
	}

}END{
	print diff,count,diff/count
}'



