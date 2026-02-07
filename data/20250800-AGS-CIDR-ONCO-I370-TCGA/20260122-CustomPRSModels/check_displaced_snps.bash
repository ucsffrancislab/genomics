#!/usr/bin/env bash

#	https://claude.ai/chat/fb6fa5f0-e2b8-4a5b-8074-476eddb176a6

# Check how many SNPs are in wrong files
for vcf in /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-*/hg38_0.8/final.chr*vcf.gz ; do
	echo $vcf
	chr=$(basename "$vcf" | sed 's/final.chr\([0-9XY]*\).dose.vcf.gz/\1/')
	echo $chr
	wrong=$(bcftools view -H "$vcf" | awk -v expected="chr${chr}" '$1 != expected' | wc -l)
	total=$(bcftools view -H "$vcf" | wc -l)
	if [ "$wrong" -gt 0 ]; then
		echo "chr${chr}: ${wrong}/${total} variants in wrong file"
	fi
done
