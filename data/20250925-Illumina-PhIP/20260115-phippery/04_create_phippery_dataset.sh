#!/bin/bash
#SBATCH --job-name=create_phip_dataset
#SBATCH --output=logs/create_dataset_%j.out
#SBATCH --error=logs/create_dataset_%j.err
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4

# ==============================================================================
# Create Phippery Dataset
# ==============================================================================
# This script creates the xarray Dataset from your prepared CSV files
# using the phippery CLI's load-from-csv command
# ==============================================================================

set -euo pipefail

# Configuration
SAMPLE_TABLE="${1:-data/sample_table.csv}"
PEPTIDE_TABLE="${2:-data/peptide_table.csv}"
COUNTS_MATRIX="${3:-data/counts_matrix.csv}"
OUTPUT_FILE="${4:-results/dataset.phip}"

# Create directories
mkdir -p logs
mkdir -p "$(dirname "${OUTPUT_FILE}")"

echo "======================================================================"
echo "Creating Phippery Dataset"
echo "Date: $(date)"
echo "======================================================================"
echo ""
echo "Input files:"
echo "  Sample table:  ${SAMPLE_TABLE}"
echo "  Peptide table: ${PEPTIDE_TABLE}"
echo "  Counts matrix: ${COUNTS_MATRIX}"
echo ""
echo "Output file: ${OUTPUT_FILE}"
echo ""

# Verify input files exist
for file in "${SAMPLE_TABLE}" "${PEPTIDE_TABLE}" "${COUNTS_MATRIX}"; do
    if [ ! -f "${file}" ]; then
        echo "ERROR: Input file not found: ${file}"
        exit 1
    fi
done

# Show file sizes
echo "Input file sizes:"
ls -lh "${SAMPLE_TABLE}" "${PEPTIDE_TABLE}" "${COUNTS_MATRIX}"
echo ""

# Count rows
echo "Row counts:"
echo "  Sample table:  $(wc -l < "${SAMPLE_TABLE}") lines"
echo "  Peptide table: $(wc -l < "${PEPTIDE_TABLE}") lines"
echo "  Counts matrix: $(wc -l < "${COUNTS_MATRIX}") lines"
echo ""

# ==============================================================================
# Run phippery load-from-csv
# ==============================================================================

echo "Creating xarray dataset..."
echo ""

# Option 1: Using Singularity container (recommended)
if [ -f "containers/phippery.sif" ]; then
    echo "Using Singularity container..."
    singularity exec containers/phippery.sif \
        phippery load-from-csv \
            -s "${SAMPLE_TABLE}" \
            -p "${PEPTIDE_TABLE}" \
            -c "${COUNTS_MATRIX}" \
            -o "${OUTPUT_FILE}"

# Option 2: Using local Python environment
elif [ -f "phippery_env/bin/activate" ]; then
    echo "Using local Python environment..."
    source phippery_env/bin/activate
    phippery load-from-csv \
        -s "${SAMPLE_TABLE}" \
        -p "${PEPTIDE_TABLE}" \
        -c "${COUNTS_MATRIX}" \
        -o "${OUTPUT_FILE}"

# Option 3: Direct Python call
else
    echo "Using system Python..."
    python3 -c "
import phippery
from phippery.utils import load_from_csv

print('Loading and creating dataset...')
ds = load_from_csv(
    sample_table='${SAMPLE_TABLE}',
    peptide_table='${PEPTIDE_TABLE}',
    counts='${COUNTS_MATRIX}'
)

print(f'Dataset created:')
print(ds)

print(f'\\nSaving to ${OUTPUT_FILE}...')
phippery.dump(ds, '${OUTPUT_FILE}')
print('Done!')
"
fi

# ==============================================================================
# Verify output
# ==============================================================================

echo ""
echo "======================================================================"
echo "Verifying dataset..."
echo "======================================================================"

if [ -f "${OUTPUT_FILE}" ]; then
    echo "Output file created successfully!"
    ls -lh "${OUTPUT_FILE}"
    
    # Show dataset info
    echo ""
    echo "Dataset summary:"
    
    if [ -f "containers/phippery.sif" ]; then
        singularity exec containers/phippery.sif phippery about "${OUTPUT_FILE}"
    elif [ -f "phippery_env/bin/activate" ]; then
        source phippery_env/bin/activate
        phippery about "${OUTPUT_FILE}"
    else
        python3 -c "
import phippery
ds = phippery.load('${OUTPUT_FILE}')
print(ds)
print()
print('Enrichment layers:', list(ds.data_vars))
print('Sample metadata:', list(ds.sample_metadata.values))
print('Peptide metadata:', list(ds.peptide_metadata.values))
"
    fi
else
    echo "ERROR: Output file was not created!"
    exit 1
fi

echo ""
echo "======================================================================"
echo "Dataset creation complete!"
echo "Output: ${OUTPUT_FILE}"
echo "======================================================================"
