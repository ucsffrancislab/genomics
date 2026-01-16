#!/usr/bin/env python3
"""
format_for_phippery.py

Prepare your data files for phippery's load-from-csv command.

This script:
1. Validates that samples in counts matrix match sample_table
2. Validates that peptides in counts matrix match peptide_table
3. Reorders both dimensions to ensure alignment
4. Identifies duplicate peptides in your peptide table
5. Adds required integer index columns (sample_id, peptide_id)
6. Renames subject_id to subject_name to avoid phippery confusion
7. Outputs formatted files ready for phippery

Usage:
    python3 format_for_phippery.py \
        --sample-table sample_metadata.csv \
        --peptide-table peptide_table.csv \
        --counts-matrix counts_matrix.csv \
        --output-dir formatted_data
"""

import argparse
import pandas as pd
import numpy as np
from pathlib import Path
import sys


def load_and_validate_sample_table(path: str) -> pd.DataFrame:
    """Load sample table and validate required columns."""
    print(f"\n{'='*60}")
    print(f"Loading sample table: {path}")
    print('='*60)
    
    df = pd.read_csv(path)
    
    # Ensure sample_name is string
    if 'sample_name' not in df.columns:
        raise ValueError("Sample table must have 'sample_name' column")
    df['sample_name'] = df['sample_name'].astype(str)
    
    # Check for sample_id (will be regenerated)
    if 'sample_id' in df.columns:
        print("  NOTE: Removing existing 'sample_id' column (will be regenerated)")
        df = df.drop(columns=['sample_id'])
    
    # Rename subject_id to subject_name to avoid phippery _id convention issues
    if 'subject_id' in df.columns:
        print("  NOTE: Renaming 'subject_id' to 'subject_name' (phippery reserves _id suffix for integers)")
        df = df.rename(columns={'subject_id': 'subject_name'})
    
    # Check for duplicates
    dups = df['sample_name'].duplicated()
    if dups.any():
        print(f"ERROR: {dups.sum()} duplicate sample names found:")
        print(df[dups]['sample_name'].tolist())
        raise ValueError("Sample names must be unique")
    
    print(f"  Samples: {len(df)}")
    print(f"  Columns: {list(df.columns)}")
    
    # Check control_status
    if 'control_status' in df.columns:
        print(f"\n  Control status breakdown:")
        for status, count in df['control_status'].value_counts().items():
            print(f"    {status}: {count}")
        
        # Warn if missing required control types
        statuses = set(df['control_status'].unique())
        if 'beads_only' not in statuses:
            print("\n  WARNING: No 'beads_only' samples - Z-score calculation won't work")
        if 'library' not in statuses:
            print("  WARNING: No 'library' samples - fold enrichment won't work")
    else:
        print("\n  WARNING: No 'control_status' column - you'll need to add this")
    
    return df


def load_and_validate_peptide_table(path: str) -> pd.DataFrame:
    """Load peptide table, validate, and identify duplicates."""
    print(f"\n{'='*60}")
    print(f"Loading peptide table: {path}")
    print('='*60)
    
    df = pd.read_csv(path)
    
    # Ensure peptide_name is string
    if 'peptide_name' not in df.columns:
        # Try to find an ID column
        for col in ['id', 'peptide_id', 'ID', 'name']:
            if col in df.columns:
                df = df.rename(columns={col: 'peptide_name'})
                print(f"  Renamed '{col}' to 'peptide_name'")
                break
        else:
            raise ValueError("Peptide table must have 'peptide_name' column (or similar)")
    
    df['peptide_name'] = df['peptide_name'].astype(str)
    
    # Check for peptide_id (will be regenerated)
    if 'peptide_id' in df.columns:
        print("  NOTE: Removing existing 'peptide_id' column (will be regenerated)")
        df = df.drop(columns=['peptide_id'])
    
    # Check for oligo column (required by phippery)
    if 'oligo' not in df.columns:
        print("WARNING: No 'oligo' column found - phippery requires this")
    
    print(f"  Peptides: {len(df)}")
    print(f"  Columns: {list(df.columns)}")
    
    # Check for duplicate peptide names
    dups = df['peptide_name'].duplicated(keep=False)
    if dups.any():
        n_dup_names = df['peptide_name'].duplicated().sum()
        print(f"\n  WARNING: {n_dup_names} duplicate peptide names found!")
        print(f"  Total rows with duplicated names: {dups.sum()}")
        
        # Show details of duplicates
        dup_df = df[dups].sort_values('peptide_name')
        print(f"\n  Duplicate peptide details (first 20):")
        
        # Group by peptide_name and show differences
        for name, group in list(dup_df.groupby('peptide_name'))[:10]:
            print(f"\n    {name} ({len(group)} occurrences):")
            # Show columns that differ
            for col in group.columns:
                if col != 'peptide_name':
                    unique_vals = group[col].unique()
                    if len(unique_vals) > 1:
                        print(f"      {col}: {list(unique_vals)}")
        
        return df, True  # Return flag indicating duplicates exist
    
    return df, False


def load_counts_matrix(path: str) -> pd.DataFrame:
    """Load counts matrix."""
    print(f"\n{'='*60}")
    print(f"Loading counts matrix: {path}")
    print('='*60)
    
    # Check if first column is an index
    preview = pd.read_csv(path, nrows=2)
    first_col = preview.columns[0]
    
    # If first column looks like peptide IDs, use it as index
    if first_col in ['', 'id', 'peptide_id', 'peptide_name', 'Unnamed: 0'] or \
       preview[first_col].dtype == object:
        print(f"  Using '{first_col}' as row index")
        df = pd.read_csv(path, index_col=0)
    else:
        df = pd.read_csv(path)
    
    # Ensure index and columns are strings
    df.index = df.index.astype(str)
    df.columns = df.columns.astype(str)
    
    print(f"  Shape: {df.shape} (peptides x samples)")
    print(f"  First few row IDs: {list(df.index[:5])}")
    print(f"  First few column names: {list(df.columns[:5])}")
    
    return df


def align_and_format(
    sample_df: pd.DataFrame,
    peptide_df: pd.DataFrame,
    counts_df: pd.DataFrame,
    output_dir: str
):
    """Align all three files and output formatted versions."""
    print(f"\n{'='*60}")
    print("Aligning data files")
    print('='*60)
    
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Get IDs from each source
    sample_names = set(sample_df['sample_name'])
    peptide_names = set(peptide_df['peptide_name'])
    counts_samples = set(counts_df.columns)
    counts_peptides = set(counts_df.index)
    
    # Check sample alignment
    print(f"\n  Sample alignment:")
    print(f"    In sample_table: {len(sample_names)}")
    print(f"    In counts_matrix columns: {len(counts_samples)}")
    
    samples_only_in_table = sample_names - counts_samples
    samples_only_in_counts = counts_samples - sample_names
    common_samples = sample_names & counts_samples
    
    if samples_only_in_table:
        print(f"    WARNING: {len(samples_only_in_table)} samples in table but not in counts:")
        print(f"      {list(samples_only_in_table)[:10]}...")
    if samples_only_in_counts:
        print(f"    WARNING: {len(samples_only_in_counts)} samples in counts but not in table:")
        print(f"      {list(samples_only_in_counts)[:10]}...")
    print(f"    Common samples: {len(common_samples)}")
    
    # Check peptide alignment
    print(f"\n  Peptide alignment:")
    print(f"    In peptide_table: {len(peptide_names)}")
    print(f"    In counts_matrix rows: {len(counts_peptides)}")
    
    peptides_only_in_table = peptide_names - counts_peptides
    peptides_only_in_counts = counts_peptides - peptide_names
    common_peptides = peptide_names & counts_peptides
    
    if peptides_only_in_table:
        print(f"    WARNING: {len(peptides_only_in_table)} peptides in table but not in counts:")
        print(f"      {list(peptides_only_in_table)[:10]}...")
    if peptides_only_in_counts:
        print(f"    WARNING: {len(peptides_only_in_counts)} peptides in counts but not in table:")
        print(f"      {list(peptides_only_in_counts)[:10]}...")
    print(f"    Common peptides: {len(common_peptides)}")
    
    if len(common_samples) == 0:
        raise ValueError("No common samples between sample_table and counts_matrix!")
    if len(common_peptides) == 0:
        raise ValueError("No common peptides between peptide_table and counts_matrix!")
    
    # Filter to common elements and align order
    print(f"\n  Filtering to common elements...")
    
    # Filter sample_table to common samples, maintain original order
    sample_df_filtered = sample_df[sample_df['sample_name'].isin(common_samples)].copy()
    sample_order = sample_df_filtered['sample_name'].tolist()
    
    # Filter peptide_table to common peptides, maintain original order
    peptide_df_filtered = peptide_df[peptide_df['peptide_name'].isin(common_peptides)].copy()
    # Drop duplicates, keeping first occurrence
    peptide_df_filtered = peptide_df_filtered.drop_duplicates(subset='peptide_name', keep='first')
    peptide_order = peptide_df_filtered['peptide_name'].tolist()
    
    # Reorder counts matrix to match
    counts_formatted = counts_df.loc[peptide_order, sample_order].copy()
    
    # Add integer ID columns as the index (required by phippery)
    # sample_id must be the index of sample_table
    sample_df_filtered = sample_df_filtered.reset_index(drop=True)
    sample_df_filtered.index.name = 'sample_id'
    
    # peptide_id must be the index of peptide_table
    peptide_df_filtered = peptide_df_filtered.reset_index(drop=True)
    peptide_df_filtered.index.name = 'peptide_id'
    
    # Counts matrix: columns = sample_id (integers), index = peptide_id (integers)
    counts_for_phippery = counts_formatted.copy()
    counts_for_phippery.columns = range(len(sample_order))
    counts_for_phippery.index = range(len(peptide_order))
    counts_for_phippery.index.name = None  # phippery reads index_col=0, expects no name
    
    print(f"\n  Final dimensions:")
    print(f"    Samples: {len(sample_order)}")
    print(f"    Peptides: {len(peptide_order)}")
    print(f"    Counts shape: {counts_for_phippery.shape}")
    
    # Save formatted files
    print(f"\n{'='*60}")
    print(f"Saving formatted files to: {output_dir}")
    print('='*60)
    
    # Sample table (with sample_id as index)
    sample_out = output_path / 'sample_table.csv'
    sample_df_filtered.to_csv(sample_out, index=True)  # index=True to write sample_id
    print(f"  Saved: {sample_out}")
    
    # Peptide table (with peptide_id as index)
    peptide_out = output_path / 'peptide_table.csv'
    peptide_df_filtered.to_csv(peptide_out, index=True)  # index=True to write peptide_id
    print(f"  Saved: {peptide_out}")
    
    # Counts matrix (with peptide_id as row index, sample_id as column headers)
    # phippery uses index_col=0 when reading, so we must include the row index
    counts_out = output_path / 'counts_matrix.csv'
    counts_for_phippery.to_csv(counts_out, index=True)  # index=True to write row index
    print(f"  Saved: {counts_out}")
    
    # Also save a human-readable version with names
    counts_readable = output_path / 'counts_matrix_readable.csv.gz'
    counts_formatted.to_csv(counts_readable, compression='gzip')
    print(f"  Saved: {counts_readable} (human-readable version)")
    
    return sample_df_filtered, peptide_df_filtered, counts_for_phippery


def main():
    parser = argparse.ArgumentParser(
        description='Format data files for phippery load-from-csv'
    )
    parser.add_argument('--sample-table', '-s', required=True,
                        help='Input sample metadata CSV')
    parser.add_argument('--peptide-table', '-p', required=True,
                        help='Input peptide annotation CSV')
    parser.add_argument('--counts-matrix', '-c', required=True,
                        help='Input counts matrix CSV')
    parser.add_argument('--output-dir', '-o', default='formatted_data',
                        help='Output directory for formatted files')
    
    args = parser.parse_args()
    
    print("="*60)
    print("Phippery Data Formatter")
    print("="*60)
    
    try:
        # Load and validate each file
        sample_df = load_and_validate_sample_table(args.sample_table)
        peptide_df, has_dups = load_and_validate_peptide_table(args.peptide_table)
        counts_df = load_counts_matrix(args.counts_matrix)
        
        if has_dups:
            print(f"\n{'!'*60}")
            print("DUPLICATE PEPTIDES DETECTED")
            print('!'*60)
            print("Your peptide table has duplicate peptide_name entries.")
            print("The script will keep only the FIRST occurrence of each peptide.")
            print("Review the duplicates above and clean your source data if needed.")
            print('!'*60)
            
#            response = input("\nContinue anyway? (y/n): ")
#            if response.lower() != 'y':
#                print("Exiting.")
#                sys.exit(1)
        
        # Align and format
        align_and_format(sample_df, peptide_df, counts_df, args.output_dir)
        
        print(f"\n{'='*60}")
        print("SUCCESS!")
        print('='*60)
        print(f"\nFormatted files are in: {args.output_dir}/")
        print("\nNext step - run phippery:")
        print(f"""
    singularity exec containers/phippery.sif \\
        phippery load-from-csv \\
            -s {args.output_dir}/sample_table.csv \\
            -p {args.output_dir}/peptide_table.csv \\
            -c {args.output_dir}/counts_matrix.csv \\
            -o dataset.phip
""")
        
    except Exception as e:
        print(f"\nERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
