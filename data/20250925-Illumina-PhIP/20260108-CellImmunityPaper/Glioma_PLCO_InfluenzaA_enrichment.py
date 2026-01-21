#!/usr/bin/env python3

from immunity_pipeline_complete import ImmunityPhIPSeqPipeline

# Initialize pipeline
pipeline = ImmunityPhIPSeqPipeline(
    rarefaction_depth=1_250_000,
    bonferroni_alpha=0.05,
    n_jobs=-1,
    # These don't matter when skip_protein_virus=True, but keeping for reference
    min_peptides_per_protein=5,
    min_proteins_per_virus=9
)

results = pipeline.run_complete_pipeline(
    counts_file="Glioma_PLCO_InfluenzaA/phipseq_counts_experimental_only.csv",
    peptide_metadata_file="InfluenzaA_peptide_metadata.csv",
    sample_metadata_file="Glioma_PLCO/sample_metadata.csv",
    output_dir="Glioma_PLCO_InfluenzaA/results",
    drop_low_depth=False,             # Drop samples with < 1.25M reads
    skip_protein_virus=True,         # NEW: Skip protein/virus aggregation
    collapse_replicates=True,        # NEW: Collapse technical replicates
    subject_col='subject_id'         # NEW: Column with subject IDs
)

# Print summary
print("\n" + "="*70)
print("PEPTIDE-LEVEL SUMMARY (By Subject)")
print("="*70)
print(f"\nTotal subjects: {len(results['peptide_enriched'].columns)}")
print(f"Total peptides analyzed: {len(results['peptide_enriched'])}")
print(f"Mean enriched peptides per subject: {results['peptide_enriched'].sum(axis=0).mean():.1f}")
print(f"Median enriched peptides per subject: {results['peptide_enriched'].sum(axis=0).median():.1f}")
print(f"Min enriched peptides: {results['peptide_enriched'].sum(axis=0).min()}")
print(f"Max enriched peptides: {results['peptide_enriched'].sum(axis=0).max()}")

# Show most prevalent peptides
print("\n" + "="*70)
print("TOP 20 MOST PREVALENT PEPTIDES")
print("="*70)
print(results['peptide_stats'].head(20))

print("\n" + "="*70)
print("NEXT STEPS")
print("="*70)
print("1. Run case-control analysis:")
print("   ./Glioma_PLCO_case_control_analysis.py")
print("\n2. Review outputs in: Glioma_PLCO/results/")
print("   - peptide_enrichment_binary.csv (subjects x peptides)")
print("   - peptide_pvalues.csv")
print("   - peptide_seropositivity_stats.csv")
