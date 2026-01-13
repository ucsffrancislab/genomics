#!/usr/bin/env python3

from case_control_analysis import CaseControlAnalyzer
import pandas as pd
import os

# Initialize analyzer
analyzer = CaseControlAnalyzer()

# Load data
print("Loading data...")
peptide_enriched = pd.read_csv("CMV_test/results/peptide_enrichment_binary.csv", index_col=0)
metadata = pd.read_csv("CMV_test/sample_metadata.csv", index_col=0)

# After collapsing replicates, we have subjects as columns
# But metadata still has all samples
# Create subject-level metadata (one row per subject)
print("Creating subject-level metadata...")
metadata_subjects = metadata.groupby('subject_id').first()

print(f"Subjects in enrichment data: {len(peptide_enriched.columns)}")
print(f"Subjects in metadata: {len(metadata_subjects)}")

# Create output directory
os.makedirs('CMV_test/results/case_control', exist_ok=True)

# Run peptide-level analysis
print("\nRunning case-control statistical testing...")
results = analyzer.test_single_entity(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    case_value='case',
    control_value='control'
)

# Apply FDR correction
results = analyzer.apply_fdr_correction(results)

# Save results
results.to_csv('CMV_test/results/case_control/peptide_results.csv', index=False)
print(f"Saved results to: CMV_test/results/case_control/peptide_results.csv")

# Print summary
print("\n" + "="*70)
print("CASE-CONTROL SUMMARY")
print("="*70)
print(f"Total peptides tested: {len(results)}")
print(f"Significant (p < 0.05): {(results['pvalue'] < 0.05).sum()}")
print(f"Significant (FDR < 0.05): {(results['fdr'] < 0.05).sum()}")
print(f"Significant (FDR < 0.01): {(results['fdr'] < 0.01).sum()}")

print("\nTop 10 most significant peptides:")
print(results.head(10)[['entity_id', 'case_prevalence', 'control_prevalence', 
                        'odds_ratio', 'pvalue', 'fdr']])

# Create visualizations
print("\n" + "="*70)
print("CREATING VISUALIZATIONS")
print("="*70)

# 1. Volcano plot
print("1. Volcano plot...")
analyzer.create_volcano_plot(
    results, 
    level_name='peptide',
    output_file='CMV_test/results/case_control/volcano_peptide.png'
)

# 2. Heatmap of top peptides
print("2. Heatmap (top 50 peptides)...")
analyzer.create_heatmap(
    peptide_enriched,
    metadata_subjects,
    results,
    top_n=50,
    output_file='CMV_test/results/case_control/heatmap_peptides.png'
)

# 3. Enrichment distribution
print("3. Enrichment distribution...")
analyzer.create_enrichment_distribution(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    output_file='CMV_test/results/case_control/enrichment_distribution.png'
)

# 4. Prevalence barplot
print("4. Prevalence barplot (top 20)...")
analyzer.create_prevalence_barplot(
    results,
    top_n=20,
    level_name='peptide',
    output_file='CMV_test/results/case_control/prevalence_peptides.png'
)

print("\n" + "="*70)
print("ANALYSIS COMPLETE!")
print("="*70)
print("\nOutput files:")
print("  CMV_test/results/case_control/")
print("    - peptide_results.csv")
print("    - volcano_peptide.png")
print("    - heatmap_peptides.png")
print("    - enrichment_distribution.png")
print("    - prevalence_peptides.png")
print("\nReview the plots and significant peptides to identify CMV-associated epitopes!")
