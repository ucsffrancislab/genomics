#!/usr/bin/env bash
#SBATCH --export=NONE      # required when using 'module'

module load CBI bcftools/1.11

dirname=$( dirname $1 )
pdirname=$( dirname $dirname )
basename=$( basename $1 .bam )

bcftools mpileup -Ou -f /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.numericXYMT_no_alts.fa ${1} | bcftools call -mv -Oz -o ${pdirname}/vcf/${basename}.vcf.gz

chmod a-w ${pdirname}/vcf/${basename}.vcf.gz

bcftools index ${pdirname}/vcf/${basename}.vcf.gz

chmod a-w ${pdirname}/vcf/${basename}.vcf.gz.csi


