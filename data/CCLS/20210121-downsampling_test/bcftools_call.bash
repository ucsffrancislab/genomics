#!/usr/bin/env bash

#module load CBI
module load bcftools

dirname=$( dirname $1 )
pdirname=$( dirname $dirname )
basename=$( basename $1 .bam )

bcftools mpileup -Ou -f /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.numeric_no_alts.fa ${1} | bcftools call -mv -Oz -o ${pdirname}/vcf/${basename}.vcf.gz

bcftools index ${pdirname}/vcf/${basename}.vcf.gz


