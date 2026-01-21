#!/usr/bin/env python3
"""
Filter peptide enrichment data by organism for focused case-control analysis.

This ensures the filtered data maintains the correct structure for analysis.
"""

import pandas as pd
import sys

def filter_enrichment_by_organism(input_enrichment, peptide_metadata, organism_name, output_enrichment):
    """
    Filter enrichment matrix to only peptides from a specific organism.
    
    Parameters:
    -----------
    input_enrichment : str
        Path to full peptide_enrichment_binary.csv
    peptide_metadata : str
        Path to peptide_metadata.csv with organism column
    organism_name : str
        Organism to filter for (e.g., 'Influenza A virus')
    output_enrichment : str
        Path to save filtered enrichment CSV
    """
    print(f"Loading enrichment data from {input_enrichment}...")
    enriched = pd.read_csv(input_enrichment, index_col=0)
    print(f"  Original: {len(enriched)} peptides × {len(enriched.columns)} samples")
    
    print(f"\nLoading peptide metadata from {peptide_metadata}...")
    metadata = pd.read_csv(peptide_metadata)
    print(f"  Metadata: {len(metadata)} peptides")
    
    # Check for organism column
    if 'organism' not in metadata.columns:
        print("ERROR: 'organism' column not found in peptide metadata!")
        print(f"Available columns: {list(metadata.columns)}")
        sys.exit(1)
    
    # Filter metadata to organism
    print(f"\nFiltering to organism: '{organism_name}'")
    organism_peptides = metadata[metadata['organism'] == organism_name]['peptide_id'].astype(str)
    print(f"  Found {len(organism_peptides)} peptides for this organism")
    
    if len(organism_peptides) == 0:
        print(f"\nERROR: No peptides found for organism '{organism_name}'")
        print(f"\nAvailable organisms:")
        print(metadata['organism'].value_counts().head(20))
        sys.exit(1)
    
    # Convert enrichment index to string for matching
    enriched.index = enriched.index.astype(str)
    
    # Filter enrichment matrix
    print(f"\nFiltering enrichment matrix...")
    common_peptides = enriched.index.intersection(organism_peptides)
    print(f"  Peptides in both enrichment and metadata: {len(common_peptides)}")
    
    if len(common_peptides) == 0:
        print("\nERROR: No peptides match between enrichment matrix and metadata!")
        print("\nEnrichment index (first 10):")
        print(enriched.index[:10].tolist())
        print("\nMetadata peptide_ids (first 10):")
        print(organism_peptides[:10].tolist())
        sys.exit(1)
    
    filtered_enriched = enriched.loc[common_peptides]
    
    # Save filtered data
    print(f"\nSaving filtered enrichment to {output_enrichment}...")
    filtered_enriched.to_csv(output_enrichment)
    print(f"  Saved: {len(filtered_enriched)} peptides × {len(filtered_enriched.columns)} samples")
    
    print("\n" + "="*70)
    print("SUCCESS!")
    print("="*70)
    print(f"Filtered enrichment data saved to: {output_enrichment}")
    print(f"Ready for case-control analysis!")
    
    return filtered_enriched


if __name__ == '__main__':
    # Example usage
    if len(sys.argv) < 5:
        print("Usage: python filter_by_organism.py <enrichment.csv> <metadata.csv> <organism> <output.csv>")
        print("\nExample:")
        print("  python filter_by_organism.py \\")
        print("    results/peptide_enrichment_binary.csv \\")
        print("    peptide_metadata.csv \\")
        print("    'Influenza A virus' \\")
        print("    results/peptide_enrichment_binary_InfluenzaA.csv")
        sys.exit(1)
    
    input_enrichment = sys.argv[1]
    peptide_metadata = sys.argv[2]
    organism_name = sys.argv[3]
    output_enrichment = sys.argv[4]
    
    filter_enrichment_by_organism(input_enrichment, peptide_metadata, organism_name, output_enrichment)
