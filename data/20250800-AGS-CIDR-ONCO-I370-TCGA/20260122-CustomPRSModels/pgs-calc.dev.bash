#!/usr/bin/env bash


module load openjdk

indir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas
outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-new_models/

mkdir -p ${outdir}

data=$1
chrnum=$2
ref=$3

threads=${SLURM_NTASKS:-4}
memory=${SLURM_MEM_PER_NODE:-10000}

scores=${outdir}/${data}/chr${chrnum}.scores.txt

if [ -f ${scores} ] && [ ! -w ${scores} ] ; then
	echo "Write-protected ${scores} exists. Skipping."
else

	cp ${indir}/imputed-umich-${data}/hg38_0.8/final.chr${chrnum}.dose.corrected.vcf.gz ${TMPDIR}/

	java -Xmx${memory}M -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply \
		${TMPDIR}/final.chr${chrnum}.dose.corrected.vcf.gz \
		--ref ${ref} \
		--out ${TMPDIR}/chr${chrnum}.scores.txt \
		--info ${TMPDIR}/chr${chrnum}.scores.info \
		--report-csv ${TMPDIR}/chr${chrnum}.scores.csv \
		--report-html ${TMPDIR}/chr${chrnum}.scores.html \
		--no-ansi --threads ${threads}

	mkdir -p ${outdir}/${data}/

	cp ${TMPDIR}/chr${chrnum}.scores.* ${outdir}/${data}/

	chmod -w ${outdir}/${data}/chr${chrnum}.scores.*

fi

