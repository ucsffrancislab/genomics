#!/usr/bin/env bash
#SBATCH --export=NONE
#SBATCH --job-name=metal_survival
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=8G

set -e  # Exit on error
set -u  # Exit on undefined variable

# RUN METAL META-ANALYSIS ON PRS SURVIVAL RESULTS

if [ $# -ne 1 ]; then
    echo "Usage: $0 <subset_file.txt>"
    echo "Example: $0 onco_allGlioma.txt"
    exit 1
fi

subset_file=$1

# Extract subset name
subset=$( basename ${subset_file} .txt )
subset=${subset#onco_}  # Remove onco_ prefix if present
subset=${subset#cidr_}  # Remove cidr_ prefix if present
subset=${subset#i370_}  # Remove i370_ prefix if present
subset=${subset#tcga_}  # Remove tcga_ prefix if present

echo "Running METAL meta-analysis for subset: ${subset}"

# METAL configuration template
METAL_TEMPLATE="survival_metal_all4.txt"

if [ ! -f "${METAL_TEMPLATE}" ]; then
    echo "Error: METAL template ${METAL_TEMPLATE} not found!"
    exit 1
fi

# Create temporary METAL config with substituted subset name
METAL_CONFIG="${TMPDIR}/metal_${subset}.txt"
sed -e "s/_SUBSETNAME/_${subset}/g" ${PWD}/${METAL_TEMPLATE} > ${METAL_CONFIG}

echo "Generated METAL configuration:"
cat ${METAL_CONFIG}
echo ""

OUT_DIR="/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-new_models-claude"
mkdir -p ${OUT_DIR}

# Run METAL
LOG_FILE="${OUT_DIR}/metal_survival_${subset}.log"
echo "Running: metal ${METAL_CONFIG}"
metal ${METAL_CONFIG} > ${LOG_FILE} 2>&1

# Check if METAL completed successfully
if [ $? -eq 0 ]; then
    echo "METAL completed successfully!"
    echo "Log file: ${LOG_FILE}"
    
    # Find output files
    OUTPUT_BASE="${OUT_DIR}/metal_survival_${subset}_"
    if [ -f "${OUTPUT_BASE}1.tbl" ]; then
        echo "Output file: ${OUTPUT_BASE}1.tbl"
        
        # Show top results
        echo ""
        echo "Top 10 results:"
        head -11 ${OUTPUT_BASE}1.tbl
    else
        echo "Warning: Expected output file ${OUTPUT_BASE}1.tbl not found"
    fi
else
    echo "Error: METAL failed! Check log file: ${LOG_FILE}"
    exit 1
fi

# Optional: Sort and extract top results
# Uncomment if you want a separate file with top 10k results sorted by p-value
# if [ -f "${OUTPUT_BASE}1.tbl" ]; then
#     head -1 ${OUTPUT_BASE}1.tbl > ${OUTPUT_BASE}1.top10k.tbl
#     tail -n +2 ${OUTPUT_BASE}1.tbl | sort -t $'\t' -k10g,10 | head -10000 >> ${OUTPUT_BASE}1.top10k.tbl
#     echo "Top 10k results saved to: ${OUTPUT_BASE}1.top10k.tbl"
# fi

echo "Done!"
