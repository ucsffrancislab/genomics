#!/usr/bin/env bash


module load openjdk

indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels

data=$1
chrnum=$2


scores=${outdir}/pgs-calc-scores/${data}/chr${chrnum}.scores.txt

if [ -f ${scores} ] && [ ! -w ${scores} ] ; then
	echo "Write-protected ${scores} exists. Skipping."
else

	cp ${indir}/imputed-umich-${data}/hg38_0.8/final.chr${chrnum}.dose.corrected.vcf.gz ${TMPDIR}/

	java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \
		${TMPDIR}/final.chr${chrnum}.dose.corrected.vcf.gz \
		--ref ${outdir}/pgs-calc_models_without_chr_prefix/pgs-collection.txt.gz \
		--out ${TMPDIR}/chr${chrnum}.scores.txt \
		--info ${TMPDIR}/chr${chrnum}.scores.info \
		--report-csv ${TMPDIR}/chr${chrnum}.scores.csv \
		--report-html ${TMPDIR}/chr${chrnum}.scores.html \
		--no-ansi --threads 8

	mkdir -p ${outdir}/pgs-calc-scores/${data}/

	cp ${TMPDIR}/chr${chrnum}.scores.* ${outdir}/pgs-calc-scores/${data}/

	chmod -w ${outdir}/pgs-calc-scores/${data}/chr${chrnum}.scores.*

fi

