#!/usr/bin/env python3
"""
04_create_phippery_dataset.py

Alternative Python script to create phippery dataset.
Better memory handling for large datasets (~115k x 1000).

Usage:
    python 04_create_phippery_dataset.py \
        --sample-table data/sample_table.csv \
        --peptide-table data/peptide_table.csv \
        --counts-matrix data/counts_matrix.csv \
        --output results/dataset.phip
"""

import argparse
import sys
import os
from pathlib import Path
import gc

os.environ['NUMEXPR_MAX_THREADS'] = '64'

import numpy as np
import pandas as pd
import xarray as xr


def create_phippery_dataset(
    sample_table_path: str,
    peptide_table_path: str,
    counts_matrix_path: str,
    output_path: str
) -> xr.Dataset:
    """Create a phippery-compatible xarray Dataset from CSV files."""
    
    print("="*60)
    print("Creating Phippery Dataset")
    print("="*60)
    
    # Load Sample Table
    print("\nLoading sample table...")
    sample_df = pd.read_csv(sample_table_path)
    if 'sample_id' not in sample_df.columns:
        sample_df.insert(0, 'sample_id', range(len(sample_df)))
    sample_df = sample_df.set_index('sample_id')
    n_samples = len(sample_df)
    print(f"  {n_samples} samples")
    
    # Load Peptide Table
    print("\nLoading peptide table...")
    peptide_df = pd.read_csv(peptide_table_path)
    if 'peptide_id' not in peptide_df.columns:
        peptide_df.insert(0, 'peptide_id', range(len(peptide_df)))
    peptide_df = peptide_df.set_index('peptide_id')
    n_peptides = len(peptide_df)
    print(f"  {n_peptides} peptides")
    
    # Load Counts Matrix
    print("\nLoading counts matrix...")
    counts_df = pd.read_csv(counts_matrix_path)
    counts = counts_df.values.astype(np.int64)
    print(f"  Shape: {counts.shape}")
    
    # Validate dimensions
    if counts.shape != (n_peptides, n_samples):
        raise ValueError(f"Shape mismatch! Expected ({n_peptides}, {n_samples}), got {counts.shape}")
    
    # Create xarray Dataset
    print("\nCreating xarray Dataset...")
    
    sample_ids = np.arange(n_samples)
    peptide_ids = np.arange(n_peptides)
    sample_metadata = list(sample_df.columns)
    peptide_metadata = list(peptide_df.columns)
    
    ds = xr.Dataset(
        data_vars={
            'counts': (['peptide_id', 'sample_id'], counts),
            'sample_table': (['sample_id', 'sample_metadata'], sample_df.values),
            'peptide_table': (['peptide_id', 'peptide_metadata'], peptide_df.values),
        },
        coords={
            'sample_id': sample_ids,
            'peptide_id': peptide_ids,
            'sample_metadata': sample_metadata,
            'peptide_metadata': peptide_metadata,
        }
    )
    
    print(f"\nDataset created:")
    print(ds)
    
    # Save
    print(f"\nSaving to {output_path}...")
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    
    # Use pickle for .phip files
    import pickle
    with open(output_path, 'wb') as f:
        pickle.dump(ds, f)
    
    print("Done!")
    return ds


def main():
    parser = argparse.ArgumentParser(description='Create phippery dataset')
    parser.add_argument('--sample-table', '-s', required=True)
    parser.add_argument('--peptide-table', '-p', required=True)
    parser.add_argument('--counts-matrix', '-c', required=True)
    parser.add_argument('--output', '-o', required=True)
    
    args = parser.parse_args()
    
    try:
        create_phippery_dataset(
            args.sample_table,
            args.peptide_table,
            args.counts_matrix,
            args.output
        )
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
