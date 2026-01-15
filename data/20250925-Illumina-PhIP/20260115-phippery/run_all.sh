#!/bin/bash
#SBATCH --job-name=phippery_pipeline
#SBATCH --output=logs/pipeline_%j.out
#SBATCH --error=logs/pipeline_%j.err
#SBATCH --time=08:00:00
#SBATCH --mem=256G
#SBATCH --cpus-per-task=64

# ==============================================================================
# Phippery Pipeline Master Script
# ==============================================================================
# This script runs the complete phippery analysis pipeline
#
# Prerequisites:
#   1. Install phippery (run 00_install_phippery.sh first)
#   2. Prepare your data in the correct format
#   3. Adjust paths below
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Configuration - ADJUST THESE FOR YOUR DATA
# ==============================================================================

# Input files (YOUR data - adjust these paths!)
INPUT_SAMPLE_METADATA="/path/to/your/sample_metadata.csv"
INPUT_PEPTIDE_ANNOTATIONS="/path/to/your/peptide_annotations.csv"  
INPUT_COUNTS_MATRIX="/path/to/your/counts_matrix.csv"

# Output directories
DATA_DIR="data"
RESULTS_DIR="results"
LOGS_DIR="logs"

# Pipeline settings
N_CORES=64
USE_SINGULARITY=true
SINGULARITY_IMAGE="containers/phippery.sif"

# ==============================================================================
# Setup
# ==============================================================================

echo "======================================================================"
echo "Phippery Pipeline"
echo "Date: $(date)"
echo "======================================================================"

# Create directories
mkdir -p "${DATA_DIR}" "${RESULTS_DIR}" "${LOGS_DIR}"

# Activate environment
if [ "${USE_SINGULARITY}" = true ] && [ -f "${SINGULARITY_IMAGE}" ]; then
    echo "Using Singularity container: ${SINGULARITY_IMAGE}"
    RUN_CMD="singularity exec ${SINGULARITY_IMAGE}"
elif [ -f "phippery_env/bin/activate" ]; then
    echo "Using local Python environment"
    source phippery_env/bin/activate
    RUN_CMD=""
else
    echo "ERROR: No phippery environment found!"
    echo "Run 00_install_phippery.sh first"
    exit 1
fi

# ==============================================================================
# Step 1: Prepare Sample Table
# ==============================================================================

echo ""
echo "======================================================================"
echo "Step 1: Preparing sample table..."
echo "======================================================================"

if [ ! -f "${DATA_DIR}/sample_table.csv" ]; then
    python scripts/01_prepare_sample_table.py \
        --input "${INPUT_SAMPLE_METADATA}" \
        --output "${DATA_DIR}/sample_table.csv" \
        --config config/pipeline_config.yaml \
        2>&1 | tee "${LOGS_DIR}/01_sample_table.log"
else
    echo "Sample table already exists: ${DATA_DIR}/sample_table.csv"
fi

# ==============================================================================
# Step 2: Prepare Peptide Table
# ==============================================================================

echo ""
echo "======================================================================"
echo "Step 2: Preparing peptide table..."
echo "======================================================================"

if [ ! -f "${DATA_DIR}/peptide_table.csv" ]; then
    python scripts/02_prepare_peptide_table.py \
        --input "${INPUT_PEPTIDE_ANNOTATIONS}" \
        --output "${DATA_DIR}/peptide_table.csv" \
        --config config/pipeline_config.yaml \
        --counts-matrix "${INPUT_COUNTS_MATRIX}" \
        2>&1 | tee "${LOGS_DIR}/02_peptide_table.log"
else
    echo "Peptide table already exists: ${DATA_DIR}/peptide_table.csv"
fi

# ==============================================================================
# Step 3: Prepare Counts Matrix
# ==============================================================================

echo ""
echo "======================================================================"
echo "Step 3: Preparing counts matrix..."
echo "======================================================================"

if [ ! -f "${DATA_DIR}/counts_matrix.csv" ]; then
    python scripts/03_prepare_counts_matrix.py \
        --input "${INPUT_COUNTS_MATRIX}" \
        --sample-table "${DATA_DIR}/sample_table.csv" \
        --peptide-table "${DATA_DIR}/peptide_table.csv" \
        --output "${DATA_DIR}/counts_matrix.csv" \
        2>&1 | tee "${LOGS_DIR}/03_counts_matrix.log"
else
    echo "Counts matrix already exists: ${DATA_DIR}/counts_matrix.csv"
fi

# ==============================================================================
# Step 4: Create Phippery Dataset
# ==============================================================================

echo ""
echo "======================================================================"
echo "Step 4: Creating phippery dataset..."
echo "======================================================================"

DATASET_FILE="${RESULTS_DIR}/dataset.phip"

if [ ! -f "${DATASET_FILE}" ]; then
    bash scripts/04_create_phippery_dataset.sh \
        "${DATA_DIR}/sample_table.csv" \
        "${DATA_DIR}/peptide_table.csv" \
        "${DATA_DIR}/counts_matrix.csv" \
        "${DATASET_FILE}" \
        2>&1 | tee "${LOGS_DIR}/04_create_dataset.log"
else
    echo "Dataset already exists: ${DATASET_FILE}"
fi

# ==============================================================================
# Step 5: Run Normalization
# ==============================================================================

echo ""
echo "======================================================================"
echo "Step 5: Running normalization..."
echo "======================================================================"

NORMALIZED_FILE="${RESULTS_DIR}/dataset_normalized.phip"

if [ ! -f "${NORMALIZED_FILE}" ]; then
    python scripts/05_run_normalization.py \
        --input "${DATASET_FILE}" \
        --output "${NORMALIZED_FILE}" \
        --cores ${N_CORES} \
        2>&1 | tee "${LOGS_DIR}/05_normalization.log"
else
    echo "Normalized dataset already exists: ${NORMALIZED_FILE}"
fi

# ==============================================================================
# Step 6: Generate QC Report
# ==============================================================================

echo ""
echo "======================================================================"
echo "Step 6: Generating QC report..."
echo "======================================================================"

python - << 'PYTHON_QC_SCRIPT'
import sys
sys.path.insert(0, '.')

import phippery
import pandas as pd
import numpy as np
from pathlib import Path

# Load dataset
ds = phippery.load('results/dataset_normalized.phip')

# Generate summary report
report = []
report.append("=" * 60)
report.append("PHIPPERY PIPELINE QC REPORT")
report.append("=" * 60)
report.append("")

# Dataset dimensions
report.append(f"Samples: {ds.dims['sample_id']}")
report.append(f"Peptides: {ds.dims['peptide_id']}")
report.append(f"Enrichment layers: {len([v for v in ds.data_vars if v not in ['sample_table', 'peptide_table']])}")
report.append("")

# Sample metadata
sample_df = ds.sample_table.to_pandas()
report.append("Sample breakdown:")
if 'control_status' in sample_df.columns:
    for status, count in sample_df['control_status'].value_counts().items():
        report.append(f"  {status}: {count}")

# Library sizes
report.append("")
report.append("Library sizes (total counts per sample):")
lib_sizes = ds['counts'].sum(dim='peptide_id').values
report.append(f"  Min: {lib_sizes.min():,.0f}")
report.append(f"  Max: {lib_sizes.max():,.0f}")
report.append(f"  Mean: {lib_sizes.mean():,.0f}")
report.append(f"  Median: {np.median(lib_sizes):,.0f}")

# Z-score stats
if 'zscore' in ds.data_vars:
    z = ds['zscore'].values
    report.append("")
    report.append("Z-score statistics:")
    report.append(f"  Range: {z.min():.2f} to {z.max():.2f}")
    report.append(f"  Hits (Z > 3.5): {(z > 3.5).sum():,}")
    report.append(f"  Hits (Z > 5.0): {(z > 5.0).sum():,}")
    report.append(f"  Hits (Z > 7.0): {(z > 7.0).sum():,}")

# Enrichment stats
if 'enrichment' in ds.data_vars:
    e = ds['enrichment'].values
    report.append("")
    report.append("Enrichment statistics:")
    report.append(f"  Range: {e.min():.4f} to {e.max():.2f}")
    report.append(f"  Enriched (>2x): {(e > 2).sum():,}")
    report.append(f"  Enriched (>5x): {(e > 5).sum():,}")
    report.append(f"  Enriched (>10x): {(e > 10).sum():,}")

# Write report
report_text = "\n".join(report)
print(report_text)

Path('results/qc_report.txt').write_text(report_text)
print("\nReport saved to: results/qc_report.txt")
PYTHON_QC_SCRIPT

# ==============================================================================
# Summary
# ==============================================================================

echo ""
echo "======================================================================"
echo "Pipeline Complete!"
echo "======================================================================"
echo ""
echo "Output files:"
ls -lh "${RESULTS_DIR}/"
echo ""
echo "Key files:"
echo "  Dataset (binary): ${RESULTS_DIR}/dataset_normalized.phip"
echo "  Counts CSV:       ${RESULTS_DIR}/dataset_normalized_counts.csv.gz"
echo "  Z-scores CSV:     ${RESULTS_DIR}/dataset_normalized_zscore.csv.gz"
echo "  Hits CSV:         ${RESULTS_DIR}/dataset_normalized_hits.csv.gz"
echo "  QC Report:        ${RESULTS_DIR}/qc_report.txt"
echo ""
echo "To load the dataset in Python:"
echo "  import phippery"
echo "  ds = phippery.load('${RESULTS_DIR}/dataset_normalized.phip')"
echo ""
echo "======================================================================"
