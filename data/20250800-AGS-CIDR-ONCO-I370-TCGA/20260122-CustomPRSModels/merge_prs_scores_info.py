#!/usr/bin/env python3
"""
Merge scores.info JSON files by replacing 3 incorrect RSID-based models with corrected versions.

Usage:
    python merge_prs_scores_info.py --dataset cidr
    python merge_prs_scores_info.py --all
"""

import json
import argparse
import sys
from pathlib import Path

# Models to replace
MODELS_TO_REPLACE = [
    'allGlioma_scoring_system',
    'gbm_scoring_system', 
    'nonGbm_scoring_system'
]

def merge_scores_info(full_catalog_file, custom_models_file, output_file, models_to_replace):
    """
    Load full catalog scores.info, drop incorrect models, add corrected models from custom file.
    
    Parameters:
    -----------
    full_catalog_file : str
        Path to full PGS catalog scores.info (with incorrect RSID models)
    custom_models_file : str
        Path to custom models scores.info (with correct versions)
    output_file : str
        Path to write merged output
    models_to_replace : list
        List of model names to replace
    """
    
    print(f"\n{'='*70}")
    print(f"Processing: {Path(full_catalog_file).name}")
    print(f"{'='*70}")
    
    # Load full catalog JSON
    print(f"\n1. Loading full catalog: {full_catalog_file}")
    with open(full_catalog_file, 'r') as f:
        catalog_data = json.load(f)
    
    print(f"   Records: {len(catalog_data)}")
    
    # Filter out models to replace
    models_present = [entry['name'] for entry in catalog_data if entry['name'] in models_to_replace]
    models_missing = [m for m in models_to_replace if m not in models_present]
    
    if models_missing:
        print(f"\n   WARNING: These models not found in catalog: {models_missing}")
    
    if not models_present:
        print(f"\n   ERROR: None of the models to replace were found in catalog!")
        return False
    
    print(f"\n   Models to replace: {models_present}")
    
    # Remove the incorrect models
    print(f"\n2. Dropping {len(models_present)} incorrect models...")
    catalog_cleaned = [entry for entry in catalog_data if entry['name'] not in models_to_replace]
    print(f"   New count: {len(catalog_cleaned)}")
    
    # Load custom models JSON
    print(f"\n3. Loading custom models: {custom_models_file}")
    with open(custom_models_file, 'r') as f:
        custom_data = json.load(f)
    
    print(f"   Records: {len(custom_data)}")
    
    # Find replacement models
    replacement_entries = [entry for entry in custom_data if entry['name'] in models_present]
    replacement_available = [entry['name'] for entry in replacement_entries]
    replacement_missing = [m for m in models_present if m not in replacement_available]
    
    if replacement_missing:
        print(f"\n   WARNING: These replacement models not found: {replacement_missing}")
    
    if not replacement_available:
        print(f"\n   ERROR: None of the replacement models found in custom file!")
        return False
    
    print(f"\n   Replacement models available: {replacement_available}")
    
    # Merge
    print(f"\n4. Merging scores.info...")
    merged_data = catalog_cleaned + replacement_entries
    
    print(f"   Merged count: {len(merged_data)}")
    
    # Verify the replacement models are present
    merged_names = [entry['name'] for entry in merged_data]
    for model in replacement_available:
        if model in merged_names:
            print(f"   ✓ {model} successfully added")
        else:
            print(f"   ✗ {model} MISSING after merge!")
    
    # Write output
    print(f"\n5. Writing merged scores.info to: {output_file}")
    Path(output_file).parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, 'w') as f:
        json.dump(merged_data, f)
    
    print(f"   ✓ Written successfully")
    
    # Summary
    print(f"\n{'='*70}")
    print(f"SUMMARY:")
    print(f"  Input (catalog):  {len(catalog_data)} records")
    print(f"  Dropped:          {len(models_present)} models")
    print(f"  Added:            {len(replacement_available)} models")
    print(f"  Output (merged):  {len(merged_data)} records")
    print(f"{'='*70}\n")
    
    return True


def main():
    parser = argparse.ArgumentParser(
        description='Merge scores.info JSON files by replacing incorrect RSID-based models'
    )
    parser.add_argument(
        '--dataset',
        choices=['cidr', 'onco', 'i370', 'tcga'],
        help='Dataset to process'
    )
    parser.add_argument(
        '--all',
        action='store_true',
        help='Process all datasets'
    )
    parser.add_argument(
        '--catalog-base',
        default='/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-new_models',
        help='Base path for full catalog scores.info'
    )
    parser.add_argument(
        '--custom-base',
        default='/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-new_models-claude',
        help='Base path for custom model scores.info'
    )
    parser.add_argument(
        '--output-base',
        default='/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/pgs-calc-scores-merged',
        help='Base path for merged output'
    )
    
    args = parser.parse_args()
    
    # Determine which datasets to process
    if args.all:
        datasets = ['cidr', 'onco', 'i370', 'tcga']
    elif args.dataset:
        datasets = [args.dataset]
    else:
        parser.error("Either --all or --dataset must be specified")
    
    # Process each dataset
    success_count = 0
    total_count = len(datasets)
    
    for dataset in datasets:
        # Construct file paths
        catalog_file = f"{args.catalog_base}/{dataset}/scores.info"
        custom_file = f"{args.custom_base}/{dataset}/scores.info"
        output_file = f"{args.output_base}/{dataset}/scores.info"
        
        print(f"\n\n{'#'*70}")
        print(f"# Processing: {dataset.upper()}")
        print(f"{'#'*70}")
        
        # Check if files exist
        if not Path(catalog_file).exists():
            print(f"ERROR: Catalog file not found: {catalog_file}")
            continue
        
        if not Path(custom_file).exists():
            print(f"ERROR: Custom file not found: {custom_file}")
            continue
        
        # Merge
        success = merge_scores_info(
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
    print(f"  Processed: {success_count}/{total_count} datasets successfully")
    if success_count < total_count:
        print(f"  Failed: {total_count - success_count}")
        sys.exit(1)
    else:
        print(f"  ✓ All datasets processed successfully!")
    print(f"{'='*70}\n")


if __name__ == '__main__':
    main()
