#!/usr/bin/env python3

from case_control_analysis import CaseControlAnalyzer

import pandas as pd

# Initialize analyzer
analyzer = CaseControlAnalyzer()

# Load data
peptide_enriched = pd.read_csv("CMV_test/results/peptide_enrichment_binary.csv", index_col=0)
protein_enriched = pd.read_csv("CMV_test/results/protein_enrichment_binary.csv", index_col=0)
virus_enriched = pd.read_csv("CMV_test/results/virus_enrichment_binary.csv", index_col=0)
metadata = pd.read_csv("CMV_test/sample_metadata.csv", index_col=0)

# Run analysis at all levels
results = analyzer.analyze_all_levels(
    peptide_enriched,
    protein_enriched,
    virus_enriched,
    metadata,
    case_col='status',
    case_value='case',
    control_value='control',
    output_dir='CMV_test/results/case_control'
)

# Create visualizations
print("\nCreating visualizations...")

# Volcano plots
analyzer.create_volcano_plot(
    results['peptide'],
    level_name='peptide',
    output_file='CMV_test/results/case_control/volcano_peptide.png'
)

analyzer.create_volcano_plot(
    results['virus'],
    level_name='virus',
    output_file='CMV_test/results/case_control/volcano_virus.png'
)

# Heatmaps
analyzer.create_heatmap(
    peptide_enriched,
    metadata,
    results['peptide'],
    top_n=50,
    output_file='CMV_test/results/case_control/heatmap_peptides.png'
)

# Prevalence plots
analyzer.create_prevalence_barplot(
    results['virus'],
    top_n=20,
    level_name='virus',
    output_file='CMV_test/results/case_control/prevalence_viruses.png'
)

print("\nAnalysis complete!")
