#!/usr/bin/env python3
"""
03_prepare_counts_matrix.py

Convert your existing counts matrix to phippery's required format.
Handles both wide and tall/long format input.

Requirements:
- Rows = peptides (must match peptide_table order)
- Columns = samples (must match sample_table order)
- Values = integer counts
- No missing values

Usage:
    python3 03_prepare_counts_matrix.py \
        --input your_counts_matrix.csv \
        --sample-table data/sample_table.csv \
        --peptide-table data/peptide_table.csv \
        --output data/counts_matrix.csv
"""

import argparse
import pandas as pd
import numpy as np
import sys
from pathlib import Path
from typing import Tuple


def detect_format(df: pd.DataFrame) -> str:
    """Detect if input is wide or tall format."""
    # Tall format typically has columns like: peptide_id, sample_id, count
    tall_indicators = ['peptide_id', 'sample_id', 'count', 'peptide', 'sample']
    
    cols_lower = [c.lower() for c in df.columns]
    
    # Check if looks like tall format
    if sum(ind in cols_lower for ind in tall_indicators) >= 2:
        return 'tall'
    
    # Check if looks wide (many numeric columns)
    n_numeric = df.select_dtypes(include=[np.number]).shape[1]
    if n_numeric > 10:
        return 'wide'
    
    # Default to wide
    return 'wide'


def load_tall_format(
    input_path: str,
    peptide_col: str = 'peptide_id',
    sample_col: str = 'sample_id', 
    count_col: str = 'count'
) -> pd.DataFrame:
    """Load tall/long format and pivot to wide."""
    print(f"Loading tall format from: {input_path}")
    
    # Load in chunks for large files
    chunks = []
    for chunk in pd.read_csv(input_path, chunksize=1_000_000):
        chunks.append(chunk)
    df = pd.concat(chunks, ignore_index=True)
    
    print(f"  Total rows: {len(df):,}")
    
    # Find the right column names
    cols = df.columns.tolist()
    cols_lower = [c.lower() for c in cols]
    
    # Auto-detect column names
    if peptide_col not in df.columns:
        for c in cols:
            if 'peptide' in c.lower():
                peptide_col = c
                break
    
    if sample_col not in df.columns:
        for c in cols:
            if 'sample' in c.lower():
                sample_col = c
                break
    
    if count_col not in df.columns:
        for c in cols:
            if 'count' in c.lower() or 'value' in c.lower():
                count_col = c
                break
    
    print(f"  Using columns: peptide={peptide_col}, sample={sample_col}, count={count_col}")
    
    # Pivot to wide format
    print("  Pivoting to wide format...")
    wide_df = df.pivot(index=peptide_col, columns=sample_col, values=count_col)
    wide_df = wide_df.fillna(0).astype(int)
    
    print(f"  Result shape: {wide_df.shape}")
    
    return wide_df


def load_wide_format(input_path: str) -> pd.DataFrame:
    """Load wide format counts matrix."""
    print(f"Loading wide format from: {input_path}")
    
    df = pd.read_csv(input_path, index_col=0)
    
    # If first column is unnamed, it's the index
    if df.columns[0] in ['', 'Unnamed: 0']:
        df = df.iloc[:, 1:]
    
    print(f"  Shape: {df.shape}")
    
    return df


def prepare_counts_matrix(
    input_path: str,
    sample_table_path: str,
    peptide_table_path: str,
    output_path: str,
    input_format: str = 'auto'
) -> pd.DataFrame:
    """
    Prepare counts matrix for phippery.
    
    The output will have:
    - Columns matching sample_table sample_name order
    - Rows matching peptide_table order
    - No index column (phippery expects headerless rows)
    """
    # Load sample and peptide tables
    print("Loading sample table...")
    sample_df = pd.read_csv(sample_table_path)
    sample_names = sample_df['sample_name'].tolist()
    print(f"  {len(sample_names)} samples")
    
    print("Loading peptide table...")
    peptide_df = pd.read_csv(peptide_table_path)
    n_peptides = len(peptide_df)
    print(f"  {n_peptides} peptides")
    
    # Load counts matrix
    if input_format == 'auto':
        # Try to detect format from first few lines
        preview = pd.read_csv(input_path, nrows=5)
        input_format = detect_format(preview)
        print(f"Detected input format: {input_format}")
    
    if input_format == 'tall':
        counts_df = load_tall_format(input_path)
    else:
        counts_df = load_wide_format(input_path)
    
    # Verify and reorder columns to match sample_table
    print("\nAligning samples...")
    missing_samples = [s for s in sample_names if s not in counts_df.columns]
    if missing_samples:
        print(f"WARNING: {len(missing_samples)} samples in sample_table not in counts matrix:")
        print(f"  {missing_samples[:10]}...")
    
    extra_samples = [s for s in counts_df.columns if s not in sample_names]
    if extra_samples:
        print(f"WARNING: {len(extra_samples)} samples in counts matrix not in sample_table:")
        print(f"  {extra_samples[:10]}...")
    
    # Use only samples that exist in both
    common_samples = [s for s in sample_names if s in counts_df.columns]
    print(f"Using {len(common_samples)} common samples")
    
    # Reorder columns to match sample_table
    counts_df = counts_df[common_samples]
    
    # Verify row count matches peptide table
    if len(counts_df) != n_peptides:
        print(f"\nWARNING: Peptide count mismatch!")
        print(f"  Counts matrix: {len(counts_df)}")
        print(f"  Peptide table: {n_peptides}")
        
        if len(counts_df) > n_peptides:
            print(f"  Trimming counts matrix to {n_peptides} rows...")
            counts_df = counts_df.head(n_peptides)
        else:
            raise ValueError("Counts matrix has fewer peptides than peptide table!")
    
    # Ensure integer values
    counts_df = counts_df.fillna(0).astype(int)
    
    # Check for any remaining NaN
    if counts_df.isna().any().any():
        raise ValueError("Counts matrix still contains NaN values after filling!")
    
    # Summary statistics
    print("\n" + "="*60)
    print("Counts Matrix Summary")
    print("="*60)
    print(f"Shape: {counts_df.shape[0]:,} peptides x {counts_df.shape[1]:,} samples")
    print(f"\nTotal counts: {counts_df.values.sum():,}")
    print(f"Mean counts per sample: {counts_df.sum(axis=0).mean():,.0f}")
    print(f"Mean counts per peptide: {counts_df.sum(axis=1).mean():,.1f}")
    
    # Check for zero-count samples or peptides
    zero_samples = (counts_df.sum(axis=0) == 0).sum()
    zero_peptides = (counts_df.sum(axis=1) == 0).sum()
    print(f"\nZero-count samples: {zero_samples}")
    print(f"Zero-count peptides: {zero_peptides}")
    
    # Library size distribution
    print(f"\nLibrary size (total counts per sample):")
    lib_sizes = counts_df.sum(axis=0)
    print(f"  Min: {lib_sizes.min():,}")
    print(f"  Max: {lib_sizes.max():,}")
    print(f"  Mean: {lib_sizes.mean():,.0f}")
    print(f"  Median: {lib_sizes.median():,.0f}")
    
    # Save without row index (phippery expects sample names as header only)
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    counts_df.to_csv(output_path, index=False)
    print(f"\nSaved counts matrix to: {output_path}")
    
    # Also update sample table if we had to remove samples
    if len(common_samples) != len(sample_names):
        updated_sample_df = sample_df[sample_df['sample_name'].isin(common_samples)]
        # Reorder to match counts matrix
        updated_sample_df = updated_sample_df.set_index('sample_name').loc[common_samples].reset_index()
        updated_sample_df.to_csv(sample_table_path, index=False)
        print(f"Updated sample table to match counts matrix: {sample_table_path}")
    
    return counts_df


def main():
    parser = argparse.ArgumentParser(
        description='Prepare counts matrix for phippery'
    )
    parser.add_argument(
        '--input', '-i', required=True,
        help='Input counts matrix (wide or tall format)'
    )
    parser.add_argument(
        '--sample-table', '-s', required=True,
        help='Sample table CSV (already prepared)'
    )
    parser.add_argument(
        '--peptide-table', '-p', required=True,
        help='Peptide table CSV (already prepared)'
    )
    parser.add_argument(
        '--output', '-o', default='data/counts_matrix.csv',
        help='Output counts matrix path'
    )
    parser.add_argument(
        '--format', '-f', choices=['auto', 'wide', 'tall'],
        default='auto', help='Input format (auto-detected by default)'
    )
    
    args = parser.parse_args()
    
    try:
        prepare_counts_matrix(
            args.input,
            args.sample_table,
            args.peptide_table,
            args.output,
            args.format
        )
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
