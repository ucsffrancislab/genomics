#!/usr/bin/env bash

#	https://claude.ai/chat/fb6fa5f0-e2b8-4a5b-8074-476eddb176a6

set -x
set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

INPUT_DIR=$1
OUTPUT_DIR=$2

threads=${SLURM_NTASKS:-4}

# Single pass: read each file once and split by actual chromosome
for input_vcf in ${INPUT_DIR}/final.chr*.dose.vcf.gz; do
    echo "Processing $(basename $input_vcf)..."
    
    # Split this file by actual chromosome coordinate
    for chr in {1..22}; do
        bcftools view --threads ${threads} -r chr${chr} ${input_vcf} -Oz -o ${TMPDIR}/chr${chr}_from_$(basename $input_vcf)
    done
done

# Now concatenate the fragments for each chromosome
for chr in {1..22}; do
    echo "Merging chr${chr}..."
    
    bcftools concat --threads ${threads} ${TMPDIR}/chr${chr}_from_*.vcf.gz | \
    bcftools sort -Oz -o ${TMPDIR}/final.chr${chr}.dose.corrected.vcf.gz
    
    bcftools index --threads ${threads} --csi ${TMPDIR}/final.chr${chr}.dose.corrected.vcf.gz
done

cp ${TMPDIR}/final.chr{?,??}.dose.corrected.vcf.gz ${OUTPUT_DIR}/
cp ${TMPDIR}/final.chr{?,??}.dose.corrected.vcf.gz.csi ${OUTPUT_DIR}/

date
echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"
echo "Done"

