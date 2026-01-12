# Understanding the Harsh Filtering

## Your Results: 115,000 → 116 → 38 peptides

This is very aggressive filtering! Let's understand what's happening and how to adjust it.

---

## The Two-Stage Filter

### Stage 1: Enrichment Calling (115,000 → 116 peptides)

**Bonferroni correction threshold:**
```
threshold = 0.05 / 115,000 = 4.3 × 10⁻⁷
```

This is EXTREMELY stringent. A peptide needs p < 0.0000004 to be called enriched in a single sample.

**Why so harsh?**
- The paper used this to control family-wise error rate
- They had 175,242 enriched peptides from 344,000 tested (50% pass rate)
- Your 116/115,000 (0.1% pass rate) suggests the method might not be well-suited to your data

### Stage 2: Prevalence Filtering (116 → 38 peptides)

**Default filter: 5-95% prevalence**
- Removes peptides enriched in <5% of samples (too rare)
- Removes peptides enriched in >95% of samples (too common)

**Your result:** Only 38 peptides have prevalence between 5-95%
- This means most of your 116 enriched peptides are very rare (< 5% of samples)

---

## How to Adjust the Filtering

### Option 1: Relax Bonferroni Threshold (Recommended)

```python
# More permissive enrichment calling
pipeline = ImmunityPhIPSeqPipeline(
    rarefaction_depth=1_250_000,
    bonferroni_alpha=0.10,  # Default is 0.05
    n_jobs=-1
)
```

Or even more permissive:
```python
pipeline = ImmunityPhIPSeqPipeline(
    bonferroni_alpha=0.50,  # Very permissive
    n_jobs=-1
)
```

**This will increase Stage 1 output significantly**

### Option 2: Adjust Prevalence Filter

```python
# After getting enriched peptides
filtered = pipeline.filter_peptides(
    enriched,
    min_prevalence=0.01,  # Down from 0.05 (keep rarer peptides)
    max_prevalence=0.99   # Up from 0.95 (keep more common peptides)
)
```

Or skip prevalence filtering entirely:
```python
# Don't filter by prevalence at all
filtered_enriched = enriched  # Use all enriched peptides
```

### Option 3: Use FDR Instead of Bonferroni

The Bonferroni correction is very conservative. You could implement FDR (False Discovery Rate) correction instead:

```python
from statsmodels.stats.multitest import multipletests

def call_enriched_with_fdr(pvalues_df, fdr_threshold=0.05):
    """
    Call enriched peptides using FDR instead of Bonferroni.
    More permissive - controls proportion of false discoveries.
    """
    enriched_fdr = pd.DataFrame(
        0, 
        index=pvalues_df.index,
        columns=pvalues_df.columns,
        dtype=int
    )
    
    for sample in pvalues_df.columns:
        # FDR correction per sample
        reject, qvalues, _, _ = multipletests(
            pvalues_df[sample].values,
            method='fdr_bh',
            alpha=fdr_threshold
        )
        enriched_fdr[sample] = reject.astype(int)
    
    return enriched_fdr
```

---

## Recommended Approach for Your Data

Based on your results (0.1% enrichment rate), I recommend:

### Try This Configuration:

```python
from immunity_phipseq_pipeline import ImmunityPhIPSeqPipeline
import pandas as pd

# Initialize with more permissive settings
pipeline = ImmunityPhIPSeqPipeline(
    rarefaction_depth=1_250_000,
    bonferroni_alpha=0.20,  # 4x more permissive
    n_jobs=-1  # Use all CPUs
)

# Load and process
counts = pd.read_csv("phipseq_counts_experimental_only.csv", index_col=0)
peptide_metadata = pd.read_csv("peptide_metadata.csv")
sample_metadata = pd.read_csv("sample_metadata.csv", index_col=0)

# Step 1: Rarefy
rarefied = pipeline.rarefy_counts(counts)

# Step 2: Call enriched (with more permissive threshold)
enriched, pvalues = pipeline.call_enriched_peptides(rarefied)

print(f"Enriched peptides with alpha=0.20: {(enriched.sum(axis=1) > 0).sum()}")

# Step 3: DON'T filter by prevalence initially
# Use all enriched peptides
filtered_enriched = enriched

# Step 4: Aggregate to protein/virus
protein_enriched = pipeline.aggregate_to_protein(filtered_enriched, peptide_metadata)
virus_enriched = pipeline.aggregate_to_virus(filtered_enriched, peptide_metadata)

# Step 5: Calculate stats
peptide_stats = pipeline.calculate_seropositivity_stats(filtered_enriched, "peptide")
protein_stats = pipeline.calculate_seropositivity_stats(protein_enriched, "protein")
virus_stats = pipeline.calculate_seropositivity_stats(virus_enriched, "virus")

# Save results
filtered_enriched.to_csv("results/peptide_enrichment_binary.csv")
protein_enriched.to_csv("results/protein_enrichment_binary.csv")
virus_enriched.to_csv("results/virus_enrichment_binary.csv")
peptide_stats.to_csv("results/peptide_seropositivity_stats.csv", index=False)
protein_stats.to_csv("results/protein_seropositivity_stats.csv", index=False)
virus_stats.to_csv("results/virus_seropositivity_stats.csv", index=False)

print("\n" + "="*70)
print("RESULTS WITH ADJUSTED FILTERING")
print("="*70)
print(f"Enriched peptides: {len(filtered_enriched)}")
print(f"Proteins: {len(protein_enriched)}")
print(f"Viruses: {len(virus_enriched)}")
```

---

## Understanding the Trade-offs

### Stringent Filtering (current)
- ✅ Very low false positive rate
- ✅ High confidence in called enrichments
- ❌ May miss real enrichments (false negatives)
- ❌ Very few peptides for analysis

### Permissive Filtering (recommended adjustment)
- ✅ More peptides for downstream analysis
- ✅ Better statistical power
- ⚠️ May include some false positives
- ✅ Can control for this in case-control analysis

---

## What the Paper Did

The Immunity 2023 paper:
- Started with 344,000 peptides
- Found 175,242 enriched (50% pass rate)
- Filtered to 2,815 peptides (5-95% prevalence)
- Used these for downstream analysis

**Your situation:**
- Started with 115,000 peptides
- Found 116 enriched (0.1% pass rate) ← **Much lower!**
- Filtered to 38 peptides (33% pass prevalence filter)

**This suggests:** The method might be too conservative for your specific library/data characteristics.

---

## Diagnostic: Why So Few Enrichments?

Possible reasons:

### 1. Library Complexity Estimation Issues
The median-based approach might not work well for your library. Check:
```python
library_complexity = rarefied.median(axis=1)
print(f"Library complexity range: {library_complexity.min()} - {library_complexity.max()}")
print(f"Median library complexity: {library_complexity.median()}")

# Check distribution
import matplotlib.pyplot as plt
plt.hist(library_complexity, bins=50)
plt.xlabel('Library Complexity (median counts)')
plt.ylabel('Number of peptides')
plt.yscale('log')
plt.savefig('library_complexity_distribution.png')
```

### 2. Low Signal-to-Noise Ratio
Your data might have high background. Check enrichment distributions:
```python
# Compare to library complexity
for sample in rarefied.columns[:5]:  # First 5 samples
    fold_change = rarefied[sample] / (library_complexity + 1)
    print(f"{sample}: max fold-change = {fold_change.max():.1f}")
```

### 3. Very Conservative Threshold
Bonferroni with 115,000 tests is extremely harsh.

---

## Comparison: Other Methods

If the Immunity method is too harsh, you could also try:

### Larman Method (uses your PLib samples)
```python
# Simple enrichment score
enrichment_score = (IP_counts / IP_total) / (PLib_counts / PLib_total)

# Or Z-score
from scipy import stats
z_scores = stats.zscore(enrichment_score, axis=0)
enriched = (z_scores > 2.5)  # Common threshold
```

Would you like me to provide a Larman-method implementation that uses your PLib samples?

---

## Summary Recommendations

**For your next run:**

1. ✅ Use `bonferroni_alpha=0.20` (or even 0.50)
2. ✅ Skip prevalence filtering initially
3. ✅ Use `n_jobs=-1` for speed
4. ✅ Check diagnostic plots of library complexity
5. ⚠️ Consider whether Immunity method suits your data
6. 🤔 Potentially try Larman method for comparison

**The fixes I made:**
1. ✅ Fixed merge error (peptide_id type mismatch)
2. ✅ Added parallelization with joblib
3. ✅ Added n_jobs parameter

Try the adjusted settings and let me know how many peptides you get!
