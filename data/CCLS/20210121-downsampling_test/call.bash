#!/usr/bin/env bash


mkdir -p vcf

for bam in bam/*bam ; do
	echo $bam
	basename=$( basename $bam .bam )

	bcftools mpileup -Ou -f /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa ${bam} | bcftools call -mv -Oz -o vcf/${basename}.vcf.gz
	bcftools index vcf/${basename}.vcf.gz

done


