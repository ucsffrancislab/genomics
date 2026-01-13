#!/usr/bin/env python3

from immunity_pipeline_complete import ImmunityPhIPSeqPipeline

# Initialize pipeline with threshold based on literature
# CMV study used threshold of 4 proteins for virus seropositivity
pipeline = ImmunityPhIPSeqPipeline(
    drop_low_depth=True,  # Drop samples with < 1.25M reads (recommended)
    rarefaction_depth=1_250_000,
    bonferroni_alpha=0.05,
    n_jobs=-1,  # Use all CPUs
    min_peptides_per_protein=5,  # At least 2 enriched peptides per protein
    min_proteins_per_virus=5     # At least 4 proteins per virus (CMV study threshold)
)

results = pipeline.run_complete_pipeline(
    counts_file="CMV_test/phipseq_counts_experimental_only.csv",
    peptide_metadata_file="peptide_metadata.csv",
    sample_metadata_file="CMV_test/sample_metadata.csv",
    output_dir="CMV_test/results"
)

# Print summary
print("\n" + "="*70)
print("SUMMARY")
print("="*70)
print(f"\nPeptide level:")
print(f"  Total enriched peptides: {len(results['peptide_enriched'])}")
print(f"  Mean seroprevalence: {results['peptide_stats']['seroprevalence'].mean():.3f}")

print(f"\nProtein level:")
print(f"  Total proteins: {len(results['protein_enriched'])}")
print(f"  Mean seroprevalence: {results['protein_stats']['seroprevalence'].mean():.3f}")

print(f"\nVirus level:")
print(f"  Total viruses: {len(results['virus_enriched'])}")
print(f"  Mean seroprevalence: {results['virus_stats']['seroprevalence'].mean():.3f}")

print("\n" + "="*70)
print("CMV-SPECIFIC RESULTS")
print("="*70)

# Check CMV specifically
#cmv_viruses = results['virus_stats'][results['virus_stats']['virus_id'].str.contains('CMV|cytomegalovirus', case=False, na=False)]
cmv_viruses = results['virus_stats'][results['virus_stats']['virus_id'].str.contains('Human herpesvirus 5', case=False, na=False)]
if len(cmv_viruses) > 0:
    print("\nCMV virus seropositivity:")
    print(cmv_viruses)
    
    # Get CMV from virus_enriched
    #cmv_mask = results['virus_enriched'].index.str.contains('CMV|cytomegalovirus', case=False, na=False)
    cmv_mask = results['virus_enriched'].index.str.contains('Human herpesvirus 5', case=False, na=False)
    if cmv_mask.any():
        cmv_data = results['virus_enriched'][cmv_mask]
        print(f"\nCMV-positive samples: {cmv_data.sum(axis=0).sum()} out of {len(cmv_data.columns)}")
        print(f"CMV seroprevalence: {cmv_data.sum(axis=0).sum() / len(cmv_data.columns):.1%}")
else:
    print("\nNo CMV viruses found in results (may need to adjust thresholds)")

# Show CMV proteins
#cmv_proteins = results['protein_stats'][results['protein_stats']['protein_id'].str.contains('CMV|cytomegalovirus', case=False, na=False)]
cmv_proteins = results['protein_stats'][results['protein_stats']['protein_id'].str.contains('Human herpesvirus 5', case=False, na=False)]
if len(cmv_proteins) > 0:
    print(f"\nCMV proteins detected: {len(cmv_proteins)}")
    print("\nTop 10 most prevalent CMV proteins:")
    print(cmv_proteins.head(10))

print("\n" + "="*70)
print("THRESHOLD ADJUSTMENT GUIDE")
print("="*70)
print("\nIf results are too sensitive (everyone CMV+):")
print("  - Increase min_peptides_per_protein (try 3-5)")
print("  - Increase min_proteins_per_virus (try 5-10)")
print("\nIf results are too conservative (no one CMV+):")
print("  - Decrease min_peptides_per_protein (try 1)")
print("  - Decrease min_proteins_per_virus (try 2-3)")
print("\nRe-run with different thresholds:")
print("  pipeline = ImmunityPhIPSeqPipeline(")
print("      min_peptides_per_protein=X,")
print("      min_proteins_per_virus=Y")
print("  )")

