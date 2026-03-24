#!/usr/bin/env bash

#	https://claude.ai/chat/fb6fa5f0-e2b8-4a5b-8074-476eddb176a6

set -x
set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

INPUT_VCF=$1

threads=${SLURM_NTASKS:-4}

TEMP_DIR="$( dirname ${INPUT_VCF} )/redistribution_temp"
mkdir -p "${TEMP_DIR}"

# read each file and split by actual chromosome
echo "Processing $(basename $INPUT_VCF)..."
    
# Split this file by actual chromosome coordinate
for chr in {1..22}; do
	bcftools view --threads ${threads} -r chr${chr} ${INPUT_VCF} -Oz -o ${TEMP_DIR}/chr${chr}_from_$(basename $INPUT_VCF)
done


date
echo "Runtime : $((SECONDS/3600)) hrs $((SECONDS%3600/60)) mins $((SECONDS%3600%60)) secs"
echo "Done"

