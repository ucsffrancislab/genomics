#!/usr/bin/env python3
"""
01_prepare_sample_table.py

Convert your existing sample metadata to phippery's required format.
Handles the mapping of your column names and control status values.

Usage:
    python3 01_prepare_sample_table.py \
        --input your_sample_metadata.csv \
        --output data/sample_table.csv \
        --config config/pipeline_config.yaml
"""

import argparse
import pandas as pd
import numpy as np
import yaml
import sys
from pathlib import Path
from typing import Dict, Optional


def load_config(config_path: str) -> dict:
    """Load pipeline configuration."""
    with open(config_path, 'r') as f:
        return yaml.safe_load(f)


def validate_control_status(df: pd.DataFrame, col: str) -> None:
    """Validate control_status column has required values."""
    valid_values = {'empirical', 'beads_only', 'library'}
    actual_values = set(df[col].dropna().unique())
    
    if not actual_values.issubset(valid_values):
        invalid = actual_values - valid_values
        raise ValueError(
            f"Invalid control_status values found: {invalid}\n"
            f"Valid values are: {valid_values}"
        )
    
    # Check we have the required control types
    if 'beads_only' not in actual_values:
        print("WARNING: No 'beads_only' samples found. Z-score analysis will not work.")
    if 'library' not in actual_values:
        print("WARNING: No 'library' samples found. CPM enrichment will not work.")


def prepare_sample_table(
    input_path: str,
    output_path: str,
    config: dict,
    counts_matrix_path: Optional[str] = None
) -> pd.DataFrame:
    """
    Prepare sample table for phippery.
    
    Parameters
    ----------
    input_path : str
        Path to your sample metadata CSV
    output_path : str
        Path to write formatted sample table
    config : dict
        Pipeline configuration
    counts_matrix_path : str, optional
        Path to counts matrix (to verify sample order)
        
    Returns
    -------
    pd.DataFrame
        Formatted sample table
    """
    print(f"Loading sample metadata from: {input_path}")
    df = pd.read_csv(input_path)
    
    print(f"  Found {len(df)} samples")
    print(f"  Columns: {list(df.columns)}")
    
    # Get column mappings from config
    col_map = config.get('sample_columns', {})
    status_map = config.get('control_status_mapping', {})
    
    # Create output dataframe
    out_df = pd.DataFrame()
    
    # Map sample_name (required)
    sample_name_col = col_map.get('sample_name', 'sample_name')
    if sample_name_col in df.columns:
        out_df['sample_name'] = df[sample_name_col].astype(str)
    else:
        raise ValueError(f"Sample name column '{sample_name_col}' not found in input")
    
    # Map control_status (required)
    control_col = col_map.get('control_status', 'control_status')
    if control_col in df.columns:
        # Apply value mapping if provided
        if status_map:
            out_df['control_status'] = df[control_col].map(
                lambda x: status_map.get(str(x), str(x))
            )
        else:
            out_df['control_status'] = df[control_col].astype(str)
    else:
        print(f"WARNING: Control status column '{control_col}' not found.")
        print("  You must add a 'control_status' column manually!")
        out_df['control_status'] = 'empirical'  # Default
    
    # Map optional columns
    optional_cols = ['plate', 'batch', 'subject_id', 'replicate', 'group', 'sex', 'age']
    for col in optional_cols:
        src_col = col_map.get(col, col)
        if src_col in df.columns:
            out_df[col] = df[src_col]
            print(f"  Mapped '{src_col}' -> '{col}'")
    
    # Validate control_status
    validate_control_status(out_df, 'control_status')
    
    # Check for duplicate sample names
    if out_df['sample_name'].duplicated().any():
        dups = out_df[out_df['sample_name'].duplicated()]['sample_name'].tolist()
        raise ValueError(f"Duplicate sample names found: {dups[:10]}...")
    
    # If counts matrix provided, verify order matches
    if counts_matrix_path:
        print(f"\nVerifying sample order against counts matrix...")
        counts_cols = pd.read_csv(counts_matrix_path, nrows=0).columns.tolist()
        # Remove first column if it's a row index
        if counts_cols[0] in ['', 'peptide_id', 'Unnamed: 0']:
            counts_cols = counts_cols[1:]
        
        if list(out_df['sample_name']) != counts_cols:
            print("WARNING: Sample order doesn't match counts matrix!")
            print("  Reordering samples to match counts matrix...")
            # Reorder to match counts matrix
            out_df = out_df.set_index('sample_name').loc[counts_cols].reset_index()
    
    # DO NOT add sample_id - phippery will add this
    if 'sample_id' in out_df.columns:
        print("WARNING: Removing 'sample_id' column (phippery will auto-generate)")
        out_df = out_df.drop(columns=['sample_id'])
    
    # Summary
    print("\n" + "="*60)
    print("Sample Table Summary")
    print("="*60)
    print(f"Total samples: {len(out_df)}")
    print(f"\nControl status breakdown:")
    print(out_df['control_status'].value_counts().to_string())
    
    if 'plate' in out_df.columns:
        print(f"\nSamples per plate:")
        print(out_df['plate'].value_counts().sort_index().to_string())
    
    if 'group' in out_df.columns:
        print(f"\nGroup breakdown:")
        print(out_df['group'].value_counts().to_string())
    
    # Save
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    out_df.to_csv(output_path, index=False)
    print(f"\nSaved sample table to: {output_path}")
    
    return out_df


def main():
    parser = argparse.ArgumentParser(
        description='Prepare sample table for phippery'
    )
    parser.add_argument(
        '--input', '-i', required=True,
        help='Input sample metadata CSV'
    )
    parser.add_argument(
        '--output', '-o', default='data/sample_table.csv',
        help='Output sample table path'
    )
    parser.add_argument(
        '--config', '-c', default='config/pipeline_config.yaml',
        help='Pipeline configuration file'
    )
    parser.add_argument(
        '--counts-matrix', '-m',
        help='Optional: counts matrix to verify sample order'
    )
    
    args = parser.parse_args()
    
    # Load config if exists
    if Path(args.config).exists():
        config = load_config(args.config)
    else:
        print(f"Config file not found: {args.config}")
        print("Using default column mappings...")
        config = {}
    
    try:
        prepare_sample_table(
            args.input,
            args.output,
            config,
            args.counts_matrix
        )
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
