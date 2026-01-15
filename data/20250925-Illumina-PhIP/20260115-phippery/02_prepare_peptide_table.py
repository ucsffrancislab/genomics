#!/usr/bin/env python3
"""
02_prepare_peptide_table.py

Convert your VirScan peptide library annotations to phippery's required format.

The key requirement is the 'oligo' column containing oligonucleotide sequences.
If you don't have oligo sequences, this script can generate placeholder IDs.

Usage:
    python 02_prepare_peptide_table.py \
        --input your_peptide_annotations.csv \
        --output data/peptide_table.csv \
        --config config/pipeline_config.yaml
"""

import argparse
import pandas as pd
import numpy as np
import yaml
import sys
from pathlib import Path
from typing import Optional


def load_config(config_path: str) -> dict:
    """Load pipeline configuration."""
    with open(config_path, 'r') as f:
        return yaml.safe_load(f)


def generate_placeholder_oligos(n: int) -> list:
    """
    Generate placeholder oligo sequences.
    Use this only if you don't have the actual oligo sequences.
    """
    print("WARNING: Generating placeholder oligo sequences!")
    print("  This is only for compatibility - not for re-alignment")
    oligos = []
    for i in range(n):
        # Generate a unique 117bp sequence (typical VirScan length)
        # Using peptide ID encoded in sequence
        oligo = f"PLACEHOLDER_OLIGO_{i:06d}"
        oligos.append(oligo)
    return oligos


def prepare_peptide_table(
    input_path: str,
    output_path: str,
    config: dict,
    counts_matrix_path: Optional[str] = None
) -> pd.DataFrame:
    """
    Prepare peptide table for phippery.
    
    Parameters
    ----------
    input_path : str
        Path to your peptide annotations CSV
    output_path : str
        Path to write formatted peptide table
    config : dict
        Pipeline configuration
    counts_matrix_path : str, optional
        Path to counts matrix (to verify peptide order and count)
        
    Returns
    -------
    pd.DataFrame
        Formatted peptide table
    """
    print(f"Loading peptide annotations from: {input_path}")
    df = pd.read_csv(input_path)
    
    print(f"  Found {len(df)} peptides")
    print(f"  Columns: {list(df.columns)}")
    
    # Get column mappings from config
    col_map = config.get('peptide_columns', {})
    
    # Create output dataframe
    out_df = pd.DataFrame()
    
    # Map oligo column (required)
    oligo_col = col_map.get('oligo', 'oligo')
    if oligo_col in df.columns:
        out_df['oligo'] = df[oligo_col].astype(str)
        print(f"  Found oligo column: '{oligo_col}'")
    else:
        print(f"WARNING: Oligo column '{oligo_col}' not found!")
        print("  Checking for alternative names...")
        
        # Try alternative column names
        alternatives = ['oligo_sequence', 'oligo_seq', 'oligonucleotide', 'sequence', 'dna_seq']
        found = False
        for alt in alternatives:
            if alt in df.columns:
                out_df['oligo'] = df[alt].astype(str)
                print(f"  Using '{alt}' as oligo column")
                found = True
                break
        
        if not found:
            print("  No oligo column found - generating placeholders")
            out_df['oligo'] = generate_placeholder_oligos(len(df))
    
    # Map peptide_name
    name_col = col_map.get('peptide_name', 'peptide_name')
    if name_col in df.columns:
        out_df['peptide_name'] = df[name_col].astype(str)
    elif df.index.name or 'Unnamed: 0' in df.columns:
        # Use index as peptide name
        out_df['peptide_name'] = [f"peptide_{i:06d}" for i in range(len(df))]
    else:
        out_df['peptide_name'] = [f"peptide_{i:06d}" for i in range(len(df))]
    
    # Map optional columns
    optional_cols = [
        ('peptide_seq', 'peptide_seq'),
        ('virus', 'virus'),
        ('virus_taxid', 'virus_taxid'),
        ('protein', 'protein'),
        ('protein_accession', 'protein_accession'),
        ('start_pos', 'start_pos'),
        ('end_pos', 'end_pos')
    ]
    
    for target_col, default_source in optional_cols:
        src_col = col_map.get(target_col, default_source)
        if src_col in df.columns:
            out_df[target_col] = df[src_col]
            print(f"  Mapped '{src_col}' -> '{target_col}'")
        elif target_col in df.columns:
            out_df[target_col] = df[target_col]
            print(f"  Kept '{target_col}'")
    
    # Copy any additional columns that might be useful
    # (virus-specific info, etc.)
    additional_cols = [c for c in df.columns if c not in out_df.columns 
                       and c not in ['Unnamed: 0', ''] 
                       and not c.startswith('Unnamed')]
    for col in additional_cols[:20]:  # Limit to 20 extra columns
        out_df[col] = df[col]
        print(f"  Copied additional column: '{col}'")
    
    # Verify against counts matrix if provided
    if counts_matrix_path:
        print(f"\nVerifying peptide count against counts matrix...")
        # Count rows in counts matrix (excluding header)
        with open(counts_matrix_path, 'r') as f:
            header = f.readline()
            n_rows = sum(1 for _ in f)
        
        if n_rows != len(out_df):
            print(f"WARNING: Peptide count mismatch!")
            print(f"  Peptide table: {len(out_df)}")
            print(f"  Counts matrix: {n_rows}")
            print("  These must match exactly!")
            
            if n_rows < len(out_df):
                print(f"  Trimming peptide table to {n_rows} rows...")
                out_df = out_df.head(n_rows)
            else:
                raise ValueError("Counts matrix has more peptides than annotation file!")
    
    # DO NOT add peptide_id - phippery will add this
    if 'peptide_id' in out_df.columns:
        print("WARNING: Removing 'peptide_id' column (phippery will auto-generate)")
        out_df = out_df.drop(columns=['peptide_id'])
    
    # Summary
    print("\n" + "="*60)
    print("Peptide Table Summary")
    print("="*60)
    print(f"Total peptides: {len(out_df)}")
    
    if 'virus' in out_df.columns:
        n_viruses = out_df['virus'].nunique()
        print(f"Number of viruses: {n_viruses}")
        print("\nTop 10 viruses by peptide count:")
        print(out_df['virus'].value_counts().head(10).to_string())
    
    if 'protein' in out_df.columns:
        n_proteins = out_df['protein'].nunique()
        print(f"\nNumber of proteins: {n_proteins}")
    
    # Check oligo sequence characteristics
    oligo_lengths = out_df['oligo'].str.len()
    print(f"\nOligo length statistics:")
    print(f"  Min: {oligo_lengths.min()}")
    print(f"  Max: {oligo_lengths.max()}")
    print(f"  Mean: {oligo_lengths.mean():.1f}")
    
    # Save
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    out_df.to_csv(output_path, index=False)
    print(f"\nSaved peptide table to: {output_path}")
    
    return out_df


def main():
    parser = argparse.ArgumentParser(
        description='Prepare peptide table for phippery'
    )
    parser.add_argument(
        '--input', '-i', required=True,
        help='Input peptide annotations CSV'
    )
    parser.add_argument(
        '--output', '-o', default='data/peptide_table.csv',
        help='Output peptide table path'
    )
    parser.add_argument(
        '--config', '-c', default='config/pipeline_config.yaml',
        help='Pipeline configuration file'
    )
    parser.add_argument(
        '--counts-matrix', '-m',
        help='Optional: counts matrix to verify peptide count'
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
        prepare_peptide_table(
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
