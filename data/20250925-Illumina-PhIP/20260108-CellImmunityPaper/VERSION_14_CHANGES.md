# PhIPSeq Pipeline Version 14 - Major Updates

## Changes from Previous Version

### 1. **Protein Names Now Include Organism Prefix**

**Problem:** Protein names like "UL44" or "gB" exist in multiple viruses. When grouping by protein name alone, peptides from different viruses were incorrectly combined.

**Solution:** Protein names are now composite: `organism::protein_name`

Example:
- Old: `UL44` (ambiguous - CMV? Other herpesvirus?)
- New: `Human_herpesvirus_5::UL44` (unambiguous)

This is automatically created during `load_peptide_metadata()` if both `organism` and `protein_name` columns exist.

### 2. **Adjustable Protein-Level Seropositivity Threshold**

**Problem:** Using "ANY peptide positive = protein positive" was too sensitive. Everyone was seropositive for common viruses like CMV.

**Solution:** New parameter `min_peptides_per_protein` (default: 2)

A sample is only considered seropositive for a protein if **at least N enriched peptides** from that protein are detected.

```python
pipeline = ImmunityPhIPSeqPipeline(
    min_peptides_per_protein=2  # Requires 2+ enriched peptides
)
```

### 3. **Adjustable Virus-Level Seropositivity Threshold**

**Problem:** Using "ANY protein positive = virus positive" was too sensitive.

**Solution:** New parameter `min_proteins_per_virus` (default: 2)

A sample is only considered seropositive for a virus if **at least N proteins** from that virus are seropositive.

Based on literature: One study determined a threshold of at least four recognized CMV proteins with the VirScan technology to consider seropositivity.

```python
pipeline = ImmunityPhIPSeqPipeline(
    min_proteins_per_virus=4  # Requires 4+ seropositive proteins (like CMV study)
)
```

## Usage Example

```python
from immunity_pipeline_v14 import ImmunityPhIPSeqPipeline

# Initialize with thresholds based on VirScan literature
pipeline = ImmunityPhIPSeqPipeline(
    rarefaction_depth=1_250_000,
    bonferroni_alpha=0.05,
    n_jobs=-1,
    min_peptides_per_protein=2,  # 2+ peptides per protein
    min_proteins_per_virus=4     # 4+ proteins per virus (CMV threshold)
)

results = pipeline.run_complete_pipeline(
    counts_file="phipseq_counts.csv",
    peptide_metadata_file="peptide_metadata.csv",
    sample_metadata_file="sample_metadata.csv",
    output_dir="results"
)
```

## How to Adjust Thresholds

### If Results Are Too Sensitive (Everyone Seropositive)

```python
pipeline = ImmunityPhIPSeqPipeline(
    min_peptides_per_protein=3,  # More stringent
    min_proteins_per_virus=5     # More stringent
)
```

### If Results Are Too Conservative (No One Seropositive)

```python
pipeline = ImmunityPhIPSeqPipeline(
    min_peptides_per_protein=1,  # Any peptide = protein positive
    min_proteins_per_virus=2     # Only 2 proteins needed
)
```

### To Match Original "ANY Positive" Behavior

```python
pipeline = ImmunityPhIPSeqPipeline(
    min_peptides_per_protein=1,
    min_proteins_per_virus=1
)
```

## Output Files

All outputs have the same format as before:
- `peptide_enrichment_binary.csv` - Peptides × samples (unchanged)
- `protein_enrichment_binary.csv` - Proteins × samples (now with organism prefix)
- `virus_enrichment_binary.csv` - Viruses × samples (now with threshold applied)
- `peptide_pvalues.csv` - P-values for each peptide
- `*_seropositivity_stats.csv` - Statistics files
- `pipeline_parameters.csv` - NEW: Documents the thresholds used

## Protein Naming Convention

The composite protein names follow this format:

```
organism::protein_name
```

Examples:
- `Human_herpesvirus_5::UL44`
- `Human_herpesvirus_5::gB`
- `Epstein_Barr_virus::EBNA1`
- `Human_immunodeficiency_virus_1::gp120`

This ensures that:
1. Proteins with the same name from different viruses are kept separate
2. You can easily filter by organism (split on `::`[0])
3. Protein identity is unambiguous

## Validation Against Known CMV Status

For your CMV validation cohort:

1. **At peptide level:** Your case-control analysis should still highlight CMV peptides
2. **At protein level:** Only proteins with ≥2 enriched peptides are considered seropositive
3. **At virus level:** Only viruses with ≥4 seropositive proteins are considered seropositive

This should match your ELISA gold standard much better!

## Literature Support

The thresholds are based on published VirScan studies:

- **Protein threshold:** Multiple studies require multiple peptides per protein to reduce false positives
- **Virus threshold:** CMV study used ≥4 proteins (97.85% sensitivity, 87.93% specificity against ELISA)

## Backward Compatibility

To replicate the old behavior (any peptide/protein positive):

```python
pipeline = ImmunityPhIPSeqPipeline(
    min_peptides_per_protein=1,
    min_proteins_per_virus=1
)
```

But this is NOT recommended for clinical validation!
