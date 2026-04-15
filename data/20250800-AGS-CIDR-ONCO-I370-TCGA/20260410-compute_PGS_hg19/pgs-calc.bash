#!/usr/bin/env bash

module load openjdk

indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/input
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19

data=$1
chrnum=$2


scores=${outdir}/pgs-calc-scores/${data}/chr${chrnum}.scores.txt

if [ -f ${scores} ] && [ ! -w ${scores} ] ; then
	echo "Write-protected ${scores} exists. Skipping."
else

	cp ${indir}/imputed-umich-${data}/chr${chrnum}.dose.vcf.gz ${TMPDIR}/

	java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \
		${TMPDIR}/chr${chrnum}.dose.vcf.gz \
		--ref /francislab/data1/refs/Imputation/PGSCatalog/hg19/pgs-collection.txt.gz \
		--out ${TMPDIR}/chr${chrnum}.scores.txt \
		--info ${TMPDIR}/chr${chrnum}.scores.info \
		--report-csv ${TMPDIR}/chr${chrnum}.scores.csv \
		--report-html ${TMPDIR}/chr${chrnum}.scores.html \
		--no-ansi --threads 8

	mkdir -p ${outdir}/pgs-calc-scores/${data}/

	cp ${TMPDIR}/chr${chrnum}.scores.* ${outdir}/pgs-calc-scores/${data}/

	chmod -w ${outdir}/pgs-calc-scores/${data}/chr${chrnum}.scores.*

fi


