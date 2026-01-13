#!/usr/bin/env python3

#from immunity_phipseq_pipeline import ImmunityPhIPSeqPipeline
from immunity_pipeline_complete import ImmunityPhIPSeqPipeline

pipeline = ImmunityPhIPSeqPipeline(
    rarefaction_depth=1_250_000,
    #bonferroni_alpha=0.20,
    bonferroni_alpha=0.05,
    n_jobs=-1  # Use all CPUs!
)

# And skip prevalence filtering initially
#filtered_enriched = enriched  # Don't filter by 5-95% ???????? where does this actually go

results = pipeline.run_complete_pipeline(
    counts_file="CMV_test/phipseq_counts_experimental_only.csv",  # Only patient samples
    peptide_metadata_file="peptide_metadata.csv",
    sample_metadata_file="CMV_test/sample_metadata.csv",
    output_dir="CMV_test/results"
)

# Print summary
print("\n" + "="*70)
print("SUMMARY")
print("="*70)
print(f"\nPeptide level:")
print(f"  Total enriched: {len(results['peptide_enriched'])}")
print(f"  Mean seroprevalence: {results['peptide_stats']['seroprevalence'].mean():.3f}")

print(f"\nProtein level:")
print(f"  Total proteins: {len(results['protein_enriched'])}")
print(f"  Mean seroprevalence: {results['protein_stats']['seroprevalence'].mean():.3f}")

print(f"\nVirus level:")
print(f"  Total viruses: {len(results['virus_enriched'])}")
print(f"  Mean seroprevalence: {results['virus_stats']['seroprevalence'].mean():.3f}")

print("\nTop 5 most prevalent viruses:")
print(results['virus_stats'].head())

# Check for batch effects
if results['sample_metadata'] is not None:
    plate_col = [col for col in results['sample_metadata'].columns 
                if 'plate' in col.lower() or 'batch' in col.lower()]
    if len(plate_col) > 0:
        print(f"\nBatch/Plate info loaded: {plate_col[0]}")
        print("(Use for downstream batch correction in case-control analysis)")


