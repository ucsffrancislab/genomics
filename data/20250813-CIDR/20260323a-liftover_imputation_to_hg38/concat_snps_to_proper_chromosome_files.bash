#!/usr/bin/env bash

#	https://claude.ai/chat/fb6fa5f0-e2b8-4a5b-8074-476eddb176a6

set -x
set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

INPUT_DIR=$1
OUTPUT_DIR=$2
CHR=$3

threads=${SLURM_NTASKS:-4}

# Now concatenate the fragments for each chromosome
echo "Merging chr${CHR}..."
    
bcftools concat --threads ${threads} ${INPUT_DIR}/chr${CHR}_from_*.vcf.gz | \
	bcftools sort -Oz -o ${TMPDIR}/final.chr${CHR}.dose.corrected.vcf.gz
    
bcftools index --threads ${threads} --csi ${TMPDIR}/final.chr${CHR}.dose.corrected.vcf.gz
    
mkdir -p ${OUTPUT_DIR}
cp ${TMPDIR}/final.chr${CHR}.dose.corrected.vcf.gz ${OUTPUT_DIR}/
cp ${TMPDIR}/final.chr${CHR}.dose.corrected.vcf.gz.csi ${OUTPUT_DIR}/


date
echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"
echo "Done"

