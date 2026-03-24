#!/usr/bin/env bash

CHRNUM=$1

set -x
set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

threads=${SLURM_NTASKS:-4}
memory=${SLURM_MEM_PER_NODE:-10000}

module load openjdk

INDIR=/francislab/data1/working/20250813-CIDR/20260323a-liftover_imputation_to_hg38/hg38
OUTDIR=/francislab/data1/working/20250813-CIDR/20260323b-CustomPRSModels/pgs-calc-scores
REFDIR=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc_models_without_chr_prefix

mkdir -p ${OUTDIR}

scores=${OUTDIR}/chr${CHRNUM}.scores.txt

if [ -f ${scores} ] && [ ! -w ${scores} ] ; then
	echo "Write-protected ${scores} exists. Skipping."
else

	cp ${INDIR}/final.chr${CHRNUM}.dose.corrected.vcf.gz ${TMPDIR}/

	java -Xmx${memory}M -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \
		${TMPDIR}/final.chr${CHRNUM}.dose.corrected.vcf.gz \
		--ref ${REFDIR}/pgs-collection.txt.gz \
		--out ${TMPDIR}/chr${CHRNUM}.scores.txt \
		--info ${TMPDIR}/chr${CHRNUM}.scores.info \
		--report-csv ${TMPDIR}/chr${CHRNUM}.scores.csv \
		--report-html ${TMPDIR}/chr${CHRNUM}.scores.html \
		--no-ansi --threads 8

	mkdir -p ${OUTDIR}

	cp ${TMPDIR}/chr${CHRNUM}.scores.* ${OUTDIR}/

	chmod -w ${OUTDIR}/chr${CHRNUM}.scores.*

fi

date
echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"
echo "Done"

