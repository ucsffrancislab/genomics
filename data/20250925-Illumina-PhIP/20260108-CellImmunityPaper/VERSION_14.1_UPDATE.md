# Version 14.1 Update - Low-Depth Sample Handling

## New Feature: Drop Low-Depth Samples

### Problem
Some samples may have insufficient reads for reliable rarefaction (e.g., < 1.25M reads when target is 1.25M). Previously, these samples were kept with their original (non-rarefied) counts, which could introduce bias.

### Solution
Added `drop_low_depth` parameter (default: `True`)

**When `drop_low_depth=True` (RECOMMENDED):**
- Samples with reads below `rarefaction_depth` are **excluded** from analysis
- Prevents bias from mixing rarefied and non-rarefied samples
- Standard practice in PhIPseq/VirScan studies

**When `drop_low_depth=False`:**
- Samples below threshold are kept with their original counts (not rarefied)
- Use only if you need to retain all samples despite quality concerns

### Usage

```python
from immunity_pipeline_v14 import ImmunityPhIPSeqPipeline

pipeline = ImmunityPhIPSeqPipeline(
    rarefaction_depth=1_250_000,
    bonferroni_alpha=0.05,
    n_jobs=-1,
    min_peptides_per_protein=2,
    min_proteins_per_virus=4
)

results = pipeline.run_complete_pipeline(
    counts_file="phipseq_counts.csv",
    peptide_metadata_file="peptide_metadata.csv",
    sample_metadata_file="sample_metadata.csv",
    output_dir="results",
    drop_low_depth=True  # Drop low-depth samples (RECOMMENDED)
)
```

### Output

The pipeline will now print clear messages:

```
Rarefying counts to 1,250,000 reads per sample...
  Samples below 1,250,000 reads will be DROPPED
  DROPPING: sample_3056 has only 188,227 reads (below target)
  DROPPING: sample_3056dup has only 187,206 reads (below target)
  ...
Dropped 4 low-depth samples
Remaining samples: 112
```

### When to Keep Low-Depth Samples

You might want to set `drop_low_depth=False` if:
- You have very few samples and can't afford to lose any
- Low-depth samples are critical to your study design
- You plan to handle depth normalization separately downstream

**However**, mixing rarefied and non-rarefied samples is generally not recommended and may compromise statistical validity.

### Recommendation

**Always use `drop_low_depth=True`** unless you have a specific reason not to. This is standard practice and ensures all samples are normalized to the same sequencing depth.

If you have many low-depth samples, consider:
1. Re-sequencing those samples to get more reads
2. Lowering `rarefaction_depth` if appropriate for your data
3. Excluding those samples from the analysis

The `pipeline_parameters.csv` output file now includes the `drop_low_depth` setting for reproducibility.
