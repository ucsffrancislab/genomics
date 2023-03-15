#!/usr/bin/env bash

module load samtools bcftools


vcf=$1
reference=$2


bcftools view $vcf | awk -v reference=$reference 'BEGIN{FS=OFS="\t"}
(/^#/){print;next}
{

	cmd="samtools faidx "reference" "$1":"$2"-"$2" | tail -1"
	cmd | getline ref
	close(cmd)

	#print $1,$2,$3,$4,ref

	$4=ref
	print

	#print $1,$2,$3,$4,ref

}'




