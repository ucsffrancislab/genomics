#!/usr/bin/env python3

from case_control_analysis import CaseControlAnalyzer
import pandas as pd
import os

# Initialize analyzer
analyzer = CaseControlAnalyzer(n_jobs=-1)  # Use all CPUs

# Load data
print("Loading data...")
peptide_enriched = pd.read_csv("Glioma_PLCO/results/peptide_enrichment_binary.csv", index_col=0)
metadata = pd.read_csv("Glioma_PLCO/sample_metadata.csv", index_col=0)
peptide_metadata = pd.read_csv("peptide_metadata.csv")  # Load peptide metadata

print(f"DEBUG - Sample enrichment columns (first 5): {list(peptide_enriched.columns[:5])}")
print(f"DEBUG - Sample metadata index (first 5): {list(metadata.index[:5])}")

# After collapsing replicates, we have subjects as columns
# But metadata still has all samples
# Create subject-level metadata - keep first occurrence of each subject
# IMPORTANT: Check that status/plate don't vary within a subject!
print("Creating subject-level metadata...")
print(f"  Original samples: {len(metadata)}")

# Check for inconsistencies within subjects
status_check = metadata.groupby('subject_id')['status'].nunique()
if (status_check > 1).any():
    print("WARNING: Some subjects have different status values across replicates!")
    print(status_check[status_check > 1])

# Take first row for each subject (they should all be the same)
metadata_subjects = metadata.groupby('subject_id').first()

print(f"DEBUG - Subject metadata index (first 5): {list(metadata_subjects.index[:5])}")

# FIX: Convert both to strings to ensure they match
print("\nConverting IDs to strings for matching...")
peptide_enriched.columns = peptide_enriched.columns.astype(str)
metadata_subjects.index = metadata_subjects.index.astype(str)

print(f"DEBUG - After conversion:")
print(f"  Enrichment columns (first 5): {list(peptide_enriched.columns[:5])}")
print(f"  Metadata index (first 5): {list(metadata_subjects.index[:5])}")

# Verify the status column is present
print(f"  Unique subjects: {len(metadata_subjects)}")
print(f"  Status column present: {'status' in metadata_subjects.columns}")
print(f"  Status distribution: {metadata_subjects['status'].value_counts().to_dict()}")

# Check overlap with enrichment data
common_subjects = peptide_enriched.columns.intersection(metadata_subjects.index)
print(f"  Subjects in both enrichment and metadata: {len(common_subjects)}")

if len(common_subjects) == 0:
    print("\nERROR: No subject IDs match between enrichment data and metadata!")
    print("This should not happen after type conversion!")
    import sys
    sys.exit(1)

# Create output directory
os.makedirs('Glioma_PLCO/results/case_control', exist_ok=True)

# Run peptide-level analysis
print("\nRunning case-control statistical testing...")
results = analyzer.test_single_entity(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    case_value='case',
    control_value='control',
    adjust_for_batch=True,
    batch_col='plate',
    skip_failed_batch=True,  # Use Fisher's p-value when batch adjustment fails
    peptide_metadata=peptide_metadata,  # NEW: Pass peptide metadata for merging
    min_subjects=5  # NEW: Filter rare peptides
)

# Apply FDR correction
print("\nApplying FDR correction...")
# You can adjust FDR threshold:
# - 0.05 (default, standard)
# - 0.01 (stringent, for high-confidence discoveries)
# - 0.10 (exploratory, for hypothesis generation)
#results = analyzer.apply_fdr_correction(results, fdr_threshold=0.05)
results = analyzer.apply_fdr_correction(results, fdr_threshold=0.50)

# Save results
results.to_csv('Glioma_PLCO/results/case_control/peptide_results.csv', index=False)
print(f"Saved results to: Glioma_PLCO/results/case_control/peptide_results.csv")

# Determine which p-value column to use
if 'batch_adjusted_pvalue' in results.columns:
    pval_col = 'batch_adjusted_pvalue'
elif 'pvalue' in results.columns:
    pval_col = 'pvalue'
else:
    pval_col = 'fisher_pvalue'

# Print summary
print("\n" + "="*70)
print("CASE-CONTROL SUMMARY")
print("="*70)
print(f"Total peptides tested: {len(results)}")
print(f"Significant (p < 0.05): {(results[pval_col] < 0.05).sum()}")
print(f"Significant (FDR < 0.05): {(results['fdr'] < 0.05).sum()}")
print(f"Significant (FDR < 0.01): {(results['fdr'] < 0.01).sum()}")

print("\nTop 10 most significant peptides:")
top_cols = ['peptide_id', 'case_prevalence', 'control_prevalence', 'odds_ratio', pval_col, 'fdr']
# Add organism/protein columns if they exist
if 'organism' in results.columns:
    top_cols = ['organism', 'protein_name', 'peptide_id', 'case_prevalence', 'control_prevalence', 'odds_ratio', pval_col, 'fdr']
print(results.head(10)[top_cols])

# Create visualizations
print("\n" + "="*70)
print("CREATING VISUALIZATIONS")
print("="*70)

# 1. Volcano plot
print("1. Volcano plot...")
analyzer.create_volcano_plot(
    results, 
    level_name='peptide',
    output_file='Glioma_PLCO/results/case_control/volcano_peptide.png'
)

# 2. Heatmap of top peptides
print("2. Heatmap (top 50 peptides)...")
analyzer.create_heatmap(
    peptide_enriched,
    metadata_subjects,
    results,
    top_n=50,
    output_file='Glioma_PLCO/results/case_control/heatmap_peptides.png'
)

# 3. Enrichment distribution
print("3. Enrichment distribution (histogram)...")
analyzer.create_enrichment_distribution(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    output_file='Glioma_PLCO/results/case_control/enrichment_distribution.png'
)

# 4. Prevalence barplot
print("4. Prevalence barplot (top 20)...")
analyzer.create_prevalence_barplot(
    results,
    top_n=20,
    level_name='peptide',
    output_file='Glioma_PLCO/results/case_control/prevalence_peptides.png'
)

# 5. ROC curves
print("5. ROC curves (top 10 peptides)...")
analyzer.create_roc_curve(
    results,
    peptide_enriched,
    metadata_subjects,
    top_n=10,
    output_file='Glioma_PLCO/results/case_control/roc_curve.png'
)

# 6. Venn diagram
print("6. Venn diagram (peptide overlap)...")
analyzer.create_venn_diagram(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    output_file='Glioma_PLCO/results/case_control/venn_diagram.png'
)

# 7. Effect size plot (forest plot)
print("7. Effect size plot (forest plot with CI)...")
analyzer.create_effect_size_plot(
    results,
    top_n=30,
    output_file='Glioma_PLCO/results/case_control/effect_sizes.png'
)

# 8. Cumulative prevalence
print("8. Cumulative prevalence curve...")
analyzer.create_cumulative_prevalence(
    peptide_enriched,
    metadata_subjects,
    results,
    case_col='status',
    output_file='Glioma_PLCO/results/case_control/cumulative_prevalence.png'
)

# 9. Violin plot
print("9. Violin plot (peptide count distribution)...")
analyzer.create_violin_plot(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    output_file='Glioma_PLCO/results/case_control/violin_plot.png'
)

# 10. Peptide correlation heatmap
print("10. Peptide correlation heatmap (top 50)...")
analyzer.create_peptide_correlation_heatmap(
    peptide_enriched,
    results,
    top_n=50,
    output_file='Glioma_PLCO/results/case_control/peptide_correlations.png'
)

# 11. Manhattan plots
print("11. Manhattan plot (all peptides)...")
analyzer.create_manhattan_plot(
    results,
    output_file='Glioma_PLCO/results/case_control/manhattan_plot_all.png'
)

# Organism-specific Manhattan plots
print("11a. Manhattan plot (Human herpesvirus 3)...")
analyzer.create_manhattan_plot(
    results,
    output_file='Glioma_PLCO/results/case_control/manhattan_plot_HHV3.png',
    organism_filter='Human herpesvirus 3'
)

print("11b. Manhattan plot (Human herpesvirus 4)...")
analyzer.create_manhattan_plot(
    results,
    output_file='Glioma_PLCO/results/case_control/manhattan_plot_HHV4.png',
    organism_filter='Human herpesvirus 4'
)

print("11c. Manhattan plot (Human herpesvirus 5)...")
analyzer.create_manhattan_plot(
    results,
    output_file='Glioma_PLCO/results/case_control/manhattan_plot_HHV5.png',
    organism_filter='Human herpesvirus 5'
)

print("11d. Manhattan plot (Influenza A virus)...")
analyzer.create_manhattan_plot(
    results,
    output_file='Glioma_PLCO/results/case_control/manhattan_plot_InfluenzaA.png',
    organism_filter='Influenza A virus'
)

# 12. Prevalence comparison
print("12. Prevalence comparison (side-by-side bars)...")
analyzer.create_prevalence_comparison_plot(
    results,
    top_n=30,
    output_file='Glioma_PLCO/results/case_control/prevalence_comparison.png'
)

# 13. UpSet plot (optional - requires upsetplot package)
print("13. UpSet plot (peptide combinations)...")
analyzer.create_upset_plot(
    peptide_enriched,
    results,
    metadata_subjects,
    case_col='status',
    top_n=20,
    output_file='Glioma_PLCO/results/case_control/upset_plot.png'
)

print("\n" + "="*70)
print("ANALYSIS COMPLETE!")
print("="*70)
print("\nOutput files in Glioma_PLCO/results/case_control/:")
print("  Statistical results:")
print("    - peptide_results.csv (with organism and protein_name columns)")
print("\n  Visualization files:")
print("    1.  volcano_peptide.png              - Volcano plot")
print("    2.  heatmap_peptides.png             - Clustered heatmap")
print("    3.  enrichment_distribution.png      - Histogram of peptide counts")
print("    4.  prevalence_peptides.png          - Top peptides bar chart")
print("    5.  roc_curve.png                    - ROC curves for top peptides")
print("    6.  venn_diagram.png                 - Case/control peptide overlap")
print("    7.  effect_sizes.png                 - Forest plot with confidence intervals")
print("    8.  cumulative_prevalence.png        - Cumulative coverage curve")
print("    9.  violin_plot.png                  - Distribution comparison")
print("    10. peptide_correlations.png         - Co-occurrence heatmap")
print("    11. manhattan_plot_all.png           - All peptides (directional)")
print("    11a. manhattan_plot_HHV3.png         - Human herpesvirus 3 only")
print("    11b. manhattan_plot_HHV4.png         - Human herpesvirus 4 only")
print("    11c. manhattan_plot_HHV5.png         - Human herpesvirus 5 only")
print("    11d. manhattan_plot_InfluenzaA.png   - Influenza A virus only")
print("    12. prevalence_comparison.png        - Side-by-side prevalence bars")
print("    13. upset_plot.png                   - Peptide combination sets (if available)")
print("\nNOTE: Manhattan plots are:")
print("  - Sorted by peptide_id (neighbors stay together)")
print("  - Directional: UP = enriched in cases, DOWN = enriched in controls")
print("\nReview the plots and significant peptides to identify associated epitopes!")
