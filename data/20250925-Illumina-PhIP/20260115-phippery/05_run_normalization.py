#!/usr/bin/env python3
"""
05_run_normalization.py

Run normalization and enrichment calculations on the phippery dataset.
Optimized for parallel execution on HPC.

This script performs:
1. Counts per million (CPM) normalization
2. Size factors (DESeq-style)
3. Z-score calculation against beads-only controls
4. Fold enrichment over library controls

Usage:
    python 05_run_normalization.py \
        --input results/dataset.phip \
        --output results/dataset_normalized.phip \
        --cores 64
"""

import argparse
import sys
import os
from pathlib import Path
import warnings
warnings.filterwarnings('ignore')

# Set environment for parallel processing
os.environ['NUMEXPR_MAX_THREADS'] = '64'

import numpy as np
import pandas as pd
import xarray as xr


def load_phippery():
    """Import phippery with error handling."""
    try:
        import phippery
        from phippery import load, dump
        from phippery.normalize import (
            counts_per_million, 
            size_factors,
            enrichment
        )
        from phippery.modeling import zscore
        return phippery, load, dump, counts_per_million, size_factors, enrichment, zscore
    except ImportError as e:
        print(f"ERROR: Could not import phippery: {e}")
        print("Please install phippery: pip install phippery")
        sys.exit(1)


def get_control_samples(ds, control_type: str) -> list:
    """Get sample IDs for a given control type."""
    sample_table = ds.sample_table.to_pandas()
    
    if 'control_status' not in sample_table.columns:
        raise ValueError("No 'control_status' column in sample table!")
    
    mask = sample_table['control_status'] == control_type
    if mask.sum() == 0:
        return []
    
    return sample_table[mask].index.tolist()


def run_cpm_normalization(ds, per_sample: bool = True):
    """Run counts per million normalization."""
    print("\n" + "="*60)
    print("Running CPM normalization...")
    print("="*60)
    
    phippery, load, dump, counts_per_million, size_factors, enrichment, zscore = load_phippery()
    
    counts_per_million(
        ds,
        per_sample=per_sample,
        data_table='counts',
        new_table_name='cpm',
        inplace=True
    )
    
    cpm_vals = ds['cpm'].values
    print(f"  CPM range: {cpm_vals.min():.2f} - {cpm_vals.max():.2f}")
    print(f"  CPM mean: {cpm_vals.mean():.2f}")
    
    return ds


def run_size_factors(ds):
    """Run size factors normalization (DESeq-style)."""
    print("\n" + "="*60)
    print("Running size factors normalization...")
    print("="*60)
    
    phippery, load, dump, counts_per_million, size_factors, enrichment, zscore = load_phippery()
    
    size_factors(
        ds,
        data_table='counts',
        new_table_name='size_factors',
        inplace=True
    )
    
    sf_vals = ds['size_factors'].values
    print(f"  Size factors range: {sf_vals.min():.4f} - {sf_vals.max():.4f}")
    
    return ds


def run_enrichment(ds, library_control_status: str = 'library'):
    """Run fold enrichment calculation over library controls."""
    print("\n" + "="*60)
    print("Running CPM fold enrichment...")
    print("="*60)
    
    phippery, load, dump, counts_per_million, size_factors, enrichment_fn, zscore = load_phippery()
    
    # Check for library controls
    library_samples = get_control_samples(ds, library_control_status)
    
    if not library_samples:
        print(f"  WARNING: No samples with control_status='{library_control_status}' found!")
        print("  Skipping enrichment calculation.")
        return ds
    
    print(f"  Found {len(library_samples)} library control samples")
    
    # Ensure CPM exists
    if 'cpm' not in ds.data_vars:
        print("  Running CPM first...")
        ds = run_cpm_normalization(ds)
    
    enrichment_fn(
        ds,
        data_table='cpm',
        lib_control_status=library_control_status,
        new_table_name='enrichment',
        inplace=True
    )
    
    enr_vals = ds['enrichment'].values
    print(f"  Enrichment range: {enr_vals.min():.4f} - {enr_vals.max():.2f}")
    print(f"  Enrichment > 1: {(enr_vals > 1).sum():,} / {enr_vals.size:,}")
    
    return ds


def run_zscore(ds, beads_control_status: str = 'beads_only'):
    """Run Z-score calculation against beads-only controls."""
    print("\n" + "="*60)
    print("Running Z-score calculation...")
    print("="*60)
    
    phippery, load, dump, counts_per_million, size_factors, enrichment, zscore_fn = load_phippery()
    
    # Check for beads-only controls
    beads_samples = get_control_samples(ds, beads_control_status)
    
    if not beads_samples:
        print(f"  WARNING: No samples with control_status='{beads_control_status}' found!")
        print("  Skipping Z-score calculation.")
        return ds
    
    print(f"  Found {len(beads_samples)} beads-only control samples")
    
    # Ensure CPM exists
    if 'cpm' not in ds.data_vars:
        print("  Running CPM first...")
        ds = run_cpm_normalization(ds)
    
    zscore_fn(
        ds,
        beads_only_status=beads_control_status,
        data_table='cpm',
        new_table_name='zscore',
        inplace=True
    )
    
    z_vals = ds['zscore'].values
    print(f"  Z-score range: {z_vals.min():.2f} - {z_vals.max():.2f}")
    print(f"  Z-score > 3.5: {(z_vals > 3.5).sum():,} / {z_vals.size:,}")
    print(f"  Z-score > 5.0: {(z_vals > 5.0).sum():,} / {z_vals.size:,}")
    
    return ds


def add_log_transforms(ds):
    """Add log-transformed versions of key metrics."""
    print("\n" + "="*60)
    print("Adding log transforms...")
    print("="*60)
    
    # Log2 CPM
    if 'cpm' in ds.data_vars:
        ds['log2_cpm'] = np.log2(ds['cpm'] + 1)
        print("  Added log2_cpm")
    
    # Log2 enrichment  
    if 'enrichment' in ds.data_vars:
        ds['log2_enrichment'] = np.log2(ds['enrichment'] + 0.01)
        print("  Added log2_enrichment")
    
    # Log10 counts + 1
    if 'counts' in ds.data_vars:
        ds['log10_counts'] = np.log10(ds['counts'] + 1)
        print("  Added log10_counts")
    
    return ds


def calculate_hit_calls(ds, zscore_threshold: float = 3.5):
    """Calculate binary hit calls based on Z-score threshold."""
    print("\n" + "="*60)
    print(f"Calculating hits (Z-score > {zscore_threshold})...")
    print("="*60)
    
    if 'zscore' not in ds.data_vars:
        print("  WARNING: No Z-score layer found. Run Z-score first.")
        return ds
    
    ds['hits'] = (ds['zscore'] > zscore_threshold).astype(int)
    
    n_hits = ds['hits'].values.sum()
    total = ds['hits'].values.size
    print(f"  Total hits: {n_hits:,} / {total:,} ({100*n_hits/total:.2f}%)")
    
    # Hits per sample
    hits_per_sample = ds['hits'].sum(dim='peptide_id')
    print(f"  Hits per sample: {hits_per_sample.values.mean():.1f} (mean)")
    
    return ds


def export_wide_csv(ds, output_prefix: str):
    """Export dataset to wide CSV files."""
    print("\n" + "="*60)
    print("Exporting to wide CSV...")
    print("="*60)
    
    output_dir = Path(output_prefix).parent
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Export sample table
    sample_file = f"{output_prefix}_sample_table.csv"
    ds.sample_table.to_pandas().to_csv(sample_file)
    print(f"  Saved: {sample_file}")
    
    # Export peptide table
    peptide_file = f"{output_prefix}_peptide_table.csv"
    ds.peptide_table.to_pandas().to_csv(peptide_file)
    print(f"  Saved: {peptide_file}")
    
    # Export each enrichment layer
    for layer in ds.data_vars:
        if layer in ['sample_table', 'peptide_table']:
            continue
        
        layer_file = f"{output_prefix}_{layer}.csv.gz"
        df = ds[layer].to_pandas()
        df.to_csv(layer_file, compression='gzip')
        print(f"  Saved: {layer_file}")


def run_all_normalizations(
    input_file: str,
    output_file: str,
    n_cores: int = 64,
    export_csv: bool = True
):
    """Run all normalization steps."""
    print("="*60)
    print("Phippery Normalization Pipeline")
    print("="*60)
    print(f"\nInput:  {input_file}")
    print(f"Output: {output_file}")
    print(f"Cores:  {n_cores}")
    
    # Import phippery
    phippery, load, dump, *_ = load_phippery()
    
    # Load dataset
    print("\nLoading dataset...")
    ds = load(input_file)
    print(f"  Samples: {ds.dims['sample_id']}")
    print(f"  Peptides: {ds.dims['peptide_id']}")
    print(f"  Existing layers: {list(ds.data_vars)}")
    
    # Show control status breakdown
    sample_df = ds.sample_table.to_pandas()
    if 'control_status' in sample_df.columns:
        print("\nControl status breakdown:")
        print(sample_df['control_status'].value_counts().to_string())
    
    # Run normalizations
    ds = run_cpm_normalization(ds)
    ds = run_size_factors(ds)
    ds = run_enrichment(ds)
    ds = run_zscore(ds)
    ds = add_log_transforms(ds)
    ds = calculate_hit_calls(ds)
    
    # Save dataset
    print("\n" + "="*60)
    print("Saving normalized dataset...")
    print("="*60)
    
    dump(ds, output_file)
    print(f"  Saved: {output_file}")
    
    # Show final layers
    print(f"\nFinal dataset layers: {list(ds.data_vars)}")
    
    # Export to CSV if requested
    if export_csv:
        csv_prefix = output_file.replace('.phip', '')
        export_wide_csv(ds, csv_prefix)
    
    print("\n" + "="*60)
    print("Normalization complete!")
    print("="*60)
    
    return ds


def main():
    parser = argparse.ArgumentParser(
        description='Run normalization on phippery dataset'
    )
    parser.add_argument(
        '--input', '-i', required=True,
        help='Input phippery dataset (.phip file)'
    )
    parser.add_argument(
        '--output', '-o', required=True,
        help='Output normalized dataset'
    )
    parser.add_argument(
        '--cores', '-c', type=int, default=64,
        help='Number of cores for parallel processing'
    )
    parser.add_argument(
        '--no-csv', action='store_true',
        help='Skip CSV export'
    )
    
    args = parser.parse_args()
    
    try:
        run_all_normalizations(
            args.input,
            args.output,
            args.cores,
            export_csv=not args.no_csv
        )
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
