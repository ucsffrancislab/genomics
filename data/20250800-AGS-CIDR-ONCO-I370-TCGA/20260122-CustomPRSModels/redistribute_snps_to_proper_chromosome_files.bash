#!/usr/bin/env bash

#	https://claude.ai/chat/fb6fa5f0-e2b8-4a5b-8074-476eddb176a6

set -x
set -e	#	exit if any command fails	#	the liftover command technically fails
set -u	#	Error on usage of unset variables
set -o pipefail

data=$1

threads=${SLURM_NTASKS:-4}
#memory=${SLURM_MEM_PER_NODE:-10000}

outdir="/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-${data}/hg38_0.8"
TEMP_DIR="${outdir}/redistribution_temp"
mkdir -p "${TEMP_DIR}"

# Single pass: read each file once and split by actual chromosome
for input_vcf in ${outdir}/final.chr*.dose.vcf.gz; do
    echo "Processing $(basename $input_vcf)..."
    
    # Split this file by actual chromosome coordinate
    for chr in {1..22}; do
        bcftools view --threads ${threads} -r chr${chr} ${input_vcf} -Oz -o ${TEMP_DIR}/chr${chr}_from_$(basename $input_vcf)
    done
done

# Now concatenate the fragments for each chromosome
for chr in {1..22}; do
    echo "Merging chr${chr}..."
    
    bcftools concat --threads ${threads} ${TEMP_DIR}/chr${chr}_from_*.vcf.gz | \
    bcftools sort -Oz -o ${outdir}/final.chr${chr}.dose.corrected.vcf.gz
    
    bcftools index --threads ${threads} --csi ${outdir}/final.chr${chr}.dose.corrected.vcf.gz
    
    # Clean up fragments for this chromosome
    rm ${TEMP_DIR}/chr${chr}_from_*.vcf.gz
done

rmdir "${TEMP_DIR}"


