#!/usr/bin/env python3
"""
Merge PRS score matrices by replacing 3 incorrect RSID-based models with corrected versions.

Usage:
    python merge_prs_scores.py --dataset cidr --type raw
    python merge_prs_scores.py --dataset cidr --type zscore
    
Or run all combinations:
    python merge_prs_scores.py --all
"""

import pandas as pd
import argparse
import sys
from pathlib import Path

# Models to replace
MODELS_TO_REPLACE = [
    'allGlioma_scoring_system',
    'gbm_scoring_system', 
    'nonGbm_scoring_system'
]

def merge_scores(full_catalog_file, custom_models_file, output_file, models_to_replace):
    """
    Load full catalog scores, drop incorrect models, add corrected models from custom file.
    
    Parameters:
    -----------
    full_catalog_file : str
        Path to full PGS catalog scores (with incorrect RSID models)
    custom_models_file : str
        Path to custom models scores (with correct versions)
    output_file : str
        Path to write merged output
    models_to_replace : list
        List of model names to replace
    """
    
    print(f"\n{'='*70}")
    print(f"Processing: {Path(full_catalog_file).name}")
    print(f"{'='*70}")
    
    # Load full catalog
    print(f"\n1. Loading full catalog: {full_catalog_file}")
    df_catalog = pd.read_csv(full_catalog_file, index_col=0)
    print(f"   Shape: {df_catalog.shape}")
    print(f"   Samples: {len(df_catalog)}")
    print(f"   Models: {len(df_catalog.columns)}")
    
    # Check which models to replace are actually present
    models_present = [m for m in models_to_replace if m in df_catalog.columns]
    models_missing = [m for m in models_to_replace if m not in df_catalog.columns]
    
    if models_missing:
        print(f"\n   WARNING: These models not found in catalog: {models_missing}")
    
    if not models_present:
        print(f"\n   ERROR: None of the models to replace were found in catalog!")
        print(f"   Available columns: {list(df_catalog.columns)[:10]}...")
        return False
    
    print(f"\n   Models to replace: {models_present}")
    
    # Drop the incorrect models
    print(f"\n2. Dropping {len(models_present)} incorrect models...")
    df_catalog_cleaned = df_catalog.drop(columns=models_present)
    print(f"   New shape: {df_catalog_cleaned.shape}")
    
    # Load custom models
    print(f"\n3. Loading custom models: {custom_models_file}")
    df_custom = pd.read_csv(custom_models_file, index_col=0)
    print(f"   Shape: {df_custom.shape}")
    print(f"   Samples: {len(df_custom)}")
    print(f"   Models: {len(df_custom.columns)}")
    
    # Check which replacement models are available
    replacement_available = [m for m in models_present if m in df_custom.columns]
    replacement_missing = [m for m in models_present if m not in df_custom.columns]
    
    if replacement_missing:
        print(f"\n   WARNING: These replacement models not found: {replacement_missing}")
    
    if not replacement_available:
        print(f"\n   ERROR: None of the replacement models found in custom file!")
        print(f"   Available columns: {list(df_custom.columns)[:10]}...")
        return False
    
    print(f"\n   Replacement models available: {replacement_available}")
    
    # Extract only the replacement models
    df_replacements = df_custom[replacement_available]
    
    # Check sample alignment
    print(f"\n4. Checking sample alignment...")
    catalog_samples = set(df_catalog_cleaned.index)
    custom_samples = set(df_replacements.index)
    
    common_samples = catalog_samples & custom_samples
    only_catalog = catalog_samples - custom_samples
    only_custom = custom_samples - catalog_samples
    
    print(f"   Common samples: {len(common_samples)}")
    if only_catalog:
        print(f"   Only in catalog: {len(only_catalog)}")
    if only_custom:
        print(f"   Only in custom: {len(only_custom)}")
    
    if len(common_samples) == 0:
        print(f"\n   ERROR: No common samples between files!")
        print(f"   Catalog samples (first 5): {list(df_catalog_cleaned.index)[:5]}")
        print(f"   Custom samples (first 5): {list(df_replacements.index)[:5]}")
        return False
    
    # Merge on sample IDs (inner join on common samples)
    print(f"\n5. Merging scores...")
    df_merged = pd.merge(
        df_catalog_cleaned,
        df_replacements,
        left_index=True,
        right_index=True,
        how='inner'
    )
    
    print(f"   Merged shape: {df_merged.shape}")
    print(f"   Final samples: {len(df_merged)}")
    print(f"   Final models: {len(df_merged.columns)}")
    
    # Verify the replacement models are present
    for model in replacement_available:
        if model in df_merged.columns:
            print(f"   ✓ {model} successfully added")
        else:
            print(f"   ✗ {model} MISSING after merge!")
    
    # Write output
    print(f"\n6. Writing merged scores to: {output_file}")
    Path(output_file).parent.mkdir(parents=True, exist_ok=True)
    df_merged.to_csv(output_file)
    print(f"   ✓ Written successfully")
    
    # Summary
    print(f"\n{'='*70}")
    print(f"SUMMARY:")
    print(f"  Input (catalog):  {df_catalog.shape[0]} samples × {df_catalog.shape[1]} models")
    print(f"  Dropped:          {len(models_present)} models")
    print(f"  Added:            {len(replacement_available)} models")
    print(f"  Output (merged):  {df_merged.shape[0]} samples × {df_merged.shape[1]} models")
    print(f"{'='*70}\n")
    
    return True


def main():
    parser = argparse.ArgumentParser(
        description='Merge PRS score matrices by replacing incorrect RSID-based models'
    )
    parser.add_argument(
        '--dataset',
        choices=['cidr', 'onco', 'i370', 'tcga'],
        help='Dataset to process'
    )
    parser.add_argument(
        '--type',
        choices=['raw', 'zscore'],
        help='Score type: raw or zscore'
    )
    parser.add_argument(
        '--all',
        action='store_true',
        help='Process all datasets and both types'
    )
    parser.add_argument(
        '--catalog-base',
        default='/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-new_models',
        help='Base path for full catalog scores'
    )
    parser.add_argument(
        '--custom-base',
        default='/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-new_models-claude',
        help='Base path for custom model scores'
    )
    parser.add_argument(
        '--output-base',
        default='/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-merged',
        help='Base path for merged output'
    )
    
    args = parser.parse_args()
    
    # Determine which combinations to process
    if args.all:
        datasets = ['cidr', 'onco', 'i370', 'tcga']
        types = ['raw', 'zscore']
        combinations = [(d, t) for d in datasets for t in types]
    elif args.dataset and args.type:
        combinations = [(args.dataset, args.type)]
    else:
        parser.error("Either --all or both --dataset and --type must be specified")
    
    # Process each combination
    success_count = 0
    total_count = len(combinations)
    
    for dataset, score_type in combinations:
        # Construct file paths
        if score_type == 'raw':
            catalog_file = f"{args.catalog_base}/{dataset}/scores.txt"
            custom_file = f"{args.custom_base}/{dataset}/scores.txt"
            output_file = f"{args.output_base}/{dataset}/scores.txt"
        else:  # zscore
            catalog_file = f"{args.catalog_base}/{dataset}/scores.z-scores.txt"
            custom_file = f"{args.custom_base}/{dataset}/scores.z-scores.txt"
            output_file = f"{args.output_base}/{dataset}/scores.z-scores.txt"
        
        print(f"\n\n{'#'*70}")
        print(f"# Processing: {dataset.upper()} - {score_type.upper()}")
        print(f"{'#'*70}")
        
        # Check if files exist
        if not Path(catalog_file).exists():
            print(f"ERROR: Catalog file not found: {catalog_file}")
            continue
        
        if not Path(custom_file).exists():
            print(f"ERROR: Custom file not found: {custom_file}")
            continue
        
        # Merge
        success = merge_scores(
            catalog_file,
            custom_file,
            output_file,
            MODELS_TO_REPLACE
        )
        
        if success:
            success_count += 1
    
    # Final summary
    print(f"\n\n{'='*70}")
    print(f"FINAL SUMMARY:")
    print(f"  Processed: {success_count}/{total_count} combinations successfully")
    if success_count < total_count:
        print(f"  Failed: {total_count - success_count}")
        sys.exit(1)
    else:
        print(f"  ✓ All combinations processed successfully!")
    print(f"{'='*70}\n")


if __name__ == '__main__':
    main()
