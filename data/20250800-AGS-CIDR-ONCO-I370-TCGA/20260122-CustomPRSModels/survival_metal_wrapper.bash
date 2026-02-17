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

if [ $# -ne 2 ]; then
    echo "Usage: $0 <SUBSET_FILE.txt> <METAL_IO_BASE_DIR>"
    echo "Example: $0 onco_allGlioma.txt /full/path/to/output/"
    exit 1
fi

SUBSET_FILE=$1
METAL_IO_BASE_DIR=$2


# Extract subset name
subset=$( basename ${SUBSET_FILE} .txt )
subset=${subset#onco_}  # Remove onco_ prefix if present
subset=${subset#cidr_}  # Remove cidr_ prefix if present
subset=${subset#i370_}  # Remove i370_ prefix if present
subset=${subset#tcga_}  # Remove tcga_ prefix if present

echo "Running METAL meta-analysis for subset: ${subset}"


# Create temporary METAL config with substituted subset name
METAL_CONFIG="${TMPDIR}/metal_${subset}.txt"

cat <<EOF > ${METAL_CONFIG}
# METAL meta-analysis for PRS survival analysis across 4 glioma cohorts
# Using effect-sizes (beta) and standard error with sample-size weighting

# Define meta-analysis scheme
SCHEME STDERR

# Define separation format (tab-separated from new pgscox_improved.r output)
SEPARATOR TAB

# Enable genomic correction - OFF for PRS meta-analysis (not SNP-level)
GENOMICCONTROL OFF

# Track sample sizes for proper weighting
WEIGHT N

EOF

for dataset in cidr onco i370 tcga ; do
cat <<EOF >> ${METAL_CONFIG}
# Process ${dataset} dataset
MARKER MarkerName
ALLELE Allele1 Allele2
EFFECT Effect
STDERR StdErr
PVALUE Pvalue
#LABEL N as N
PROCESS ${METAL_IO_BASE_DIR}/${dataset}/${dataset}_${subset}/${dataset}_${subset}.cox_coeffs_metal.txt

EOF
done

cat <<EOF >> ${METAL_CONFIG}
# Output file
OUTFILE ${METAL_IO_BASE_DIR}/metal_survival_${subset}_ .tbl

# Run analysis with heterogeneity testing
ANALYZE HETEROGENEITY

QUIT
EOF


echo "Generated METAL configuration:"
cat ${METAL_CONFIG}
echo ""


mkdir -p ${METAL_IO_BASE_DIR}




# Run METAL
LOG_FILE="${METAL_IO_BASE_DIR}/metal_survival_${subset}.log"
echo "Running: metal ${METAL_CONFIG}"
metal ${METAL_CONFIG} > ${LOG_FILE} 2>&1

# Check if METAL completed successfully
if [ $? -eq 0 ]; then
    echo "METAL completed successfully!"
    echo "Log file: ${LOG_FILE}"
    
    # Find output files
    OUTPUT_BASE="${METAL_IO_BASE_DIR}/metal_survival_${subset}_"
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
if [ -f "${OUTPUT_BASE}1.tbl" ]; then
    head -1 ${OUTPUT_BASE}1.tbl > ${OUTPUT_BASE}1.top10k.tbl
    tail -n +2 ${OUTPUT_BASE}1.tbl | sort -t $'\t' -k10g,10 | head -10000 >> ${OUTPUT_BASE}1.top10k.tbl
    echo "Top 10k results saved to: ${OUTPUT_BASE}1.top10k.tbl"
fi

echo "Done!"
