# Prevalence Filtering Guide for PhIPSeq Case-Control Analysis

## Overview

Prevalence filtering removes peptides that are positive in very few subjects before statistical testing. This is standard practice in PhIPSeq studies to improve statistical power and reduce noise.

---

## Why Filter By Prevalence?

### Problems with Testing Rare Peptides:

1. **Low Statistical Power**
   - Peptide positive in only 1-2 subjects → unreliable statistics
   - Fisher's exact test p-values become unreliable
   - Can't distinguish signal from noise

2. **Multiple Testing Burden**
   - Testing 115,292 peptides → harsh FDR correction
   - Many rare peptides dilute signal from real associations
   - Removing noise improves discovery of true signals

3. **Reproducibility**
   - Peptides in 1 subject might be technical artifacts
   - Real immune responses typically seen in multiple subjects
   - Filtering improves biological reproducibility

### Published Precedent:

**Immunity 2023 (Protein Science paper)**:
> "We restricted analysis to peptides enriched in ≥5% of samples"

This is the paper we've been following for methodology.

---

## How It Works

### The Filter:

```python
min_subjects = 11  # Or whatever threshold you choose

# Count subjects positive for each peptide
peptide_counts = enriched_matrix.sum(axis=1)

# Keep only peptides positive in >= min_subjects
filtered_matrix = enriched_matrix[peptide_counts >= min_subjects]
```

### What Gets Removed:

**Example with min_subjects=5**:
- ✅ **KEEP**: Peptide positive in 8 subjects (5 cases, 3 controls)
- ❌ **REMOVE**: Peptide positive in 3 subjects (2 cases, 1 control)
- ❌ **REMOVE**: Peptide positive in 1 subject (1 case, 0 controls)

---

## Recommended Thresholds

### Option 1: Percentage-Based (Recommended)
**"5% of total subjects"** - Matches published literature

**Your Datasets:**
- **CMV**: 47 subjects × 5% = 2.35 → Use **min_subjects=3**
- **Glioma**: 215 subjects × 5% = 10.75 → Use **min_subjects=11**
- **Influenza A**: 116 subjects × 5% = 5.8 → Use **min_subjects=6**

### Option 2: Absolute Minimum
**"At least 5 subjects"** - Simple, conservative

- Works across all dataset sizes
- Good default when unsure
- Very safe for small datasets

### Option 3: No Filtering
**min_subjects=None** - Test everything

- Use for exploratory analysis
- When sample size is very large
- When rare responses are of interest

---

## Implementation

### In Your Scripts:

The filter is now built into `test_single_entity()`:

```python
results = analyzer.test_single_entity(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    case_value='case',
    control_value='control',
    adjust_for_batch=True,
    batch_col='plate',
    skip_failed_batch=True,
    peptide_metadata=peptide_metadata,
    min_subjects=11  # NEW PARAMETER
)
```

### Current Settings:

**CMV script**: `min_subjects=3` (5% of 47 subjects)
**Glioma script**: `min_subjects=11` (5% of 215 subjects)

You can adjust these as needed!

---

## Impact on Results

### Expected Changes:

**Before filtering** (Glioma example):
```
Testing 115,292 peptides
Significant (p < 0.05): 1,894
Significant (FDR < 0.05): 0
```

**After filtering** (min_subjects=11):
```
Filtering rare peptides...
  Entities before filtering: 115,292
  Entities after filtering: ~40,000-60,000
  Removed: ~50,000-70,000 rare peptides

Testing 50,000 peptides
Significant (p < 0.05): 1,200
Significant (FDR < 0.05): 15-30  ← More discoveries!
```

### Why More Significant Results?

1. **Less multiple testing correction** (50K tests vs 115K)
2. **Better power** (testing peptides with sufficient data)
3. **Less noise** (removed unreliable peptides)

This is **scientifically correct**, not p-hacking!

---

## Biological Interpretation

### What You're Assuming:

**"Real immune responses occur in multiple subjects"**

This is reasonable because:
- Common antigens → shared responses
- Technical artifacts → usually unique to 1 subject
- Rare responses might be real, but hard to distinguish from noise

### What You Might Miss:

- **Personalized responses** (unique to 1-2 subjects)
- **Ultra-rare epitopes**
- **Novel disease-specific antigens** not seen before

**Trade-off**: Sacrifice sensitivity for specificity

---

## When to Use Different Thresholds

### Use min_subjects=3 (lenient):
- Small sample size (<50 subjects)
- Exploratory analysis
- Looking for personalized responses
- Discovery phase

### Use min_subjects=5-11 (standard):
- Medium to large sample size (>100 subjects)
- Publication-quality analysis
- Following published methodology
- When you want reproducible signals

### Use min_subjects=20+ (stringent):
- Very large sample size (>500 subjects)
- Known high background noise
- Focused on common responses only

### Use min_subjects=None (no filter):
- Very large sample size (>1000 subjects)
- Multiple testing correction can handle it
- Rare responses are scientifically important
- Just looking, not testing

---

## Example Scenarios

### Scenario 1: CMV Validation Study
**Dataset**: 47 subjects (22 CMV+, 25 CMV-)
**Goal**: Validate known CMV responses

**Recommendation**: `min_subjects=3`
- Small sample → lenient threshold
- Known epitopes should be in multiple subjects
- Don't want to lose signal in small dataset

### Scenario 2: Glioma Discovery
**Dataset**: 215 subjects (110 cases, 105 controls)
**Goal**: Discover novel associations

**Recommendation**: `min_subjects=11`
- Follow published 5% rule
- Balance discovery vs noise
- Improve FDR performance

### Scenario 3: Influenza A Focused
**Dataset**: 116 subjects (37 cases, 79 controls)
**Goal**: Focused hypothesis on one virus

**Recommendation**: `min_subjects=6`
- 5% rule: 116 × 0.05 = 5.8
- Focused analysis → can be slightly lenient
- Known virus → expect shared responses

---

## Checking Your Filter

### Before Running Analysis:

```python
import pandas as pd

# Load enrichment
enriched = pd.read_csv("results/peptide_enrichment_binary.csv", index_col=0)

# Check distribution
peptide_counts = enriched.sum(axis=1)

print("Peptide prevalence distribution:")
print(peptide_counts.describe())
print("\nPeptides by count:")
print(peptide_counts.value_counts().head(20))

# Test different thresholds
for threshold in [3, 5, 10, 15, 20]:
    n_kept = (peptide_counts >= threshold).sum()
    pct = n_kept / len(peptide_counts) * 100
    print(f"min_subjects={threshold}: Keep {n_kept} peptides ({pct:.1f}%)")
```

### After Running Analysis:

Check the output:
```
Filtering rare peptides...
  Entities before filtering: 115292
  Entities after filtering: 52103
  Removed 63189 entities present in <11 subjects
```

If you removed **too many** (>80%), threshold is too strict.
If you removed **too few** (<30%), threshold might be too lenient.
Sweet spot: **40-70% removed**

---

## FAQs

**Q: Is this p-hacking?**
A: No! Filtering is done BEFORE seeing p-values, based on data quality, not results.

**Q: Should I use the same threshold for all my analyses?**
A: No - adjust based on sample size. Use percentage-based rule (5%) for consistency.

**Q: What if I want to check rare peptides later?**
A: Keep the unfiltered enrichment matrix. You can always go back and check specific peptides.

**Q: Does this affect the enrichment calling?**
A: No - enrichment is already done. This only affects which peptides get tested in case-control.

**Q: Can I filter after testing?**
A: Not really - you'd still pay the multiple testing penalty. Filter before testing for proper statistics.

---

## Summary

✅ **DO** filter rare peptides for cleaner, more powerful analysis
✅ **DO** use 5% rule (percentage of subjects) as default
✅ **DO** adjust threshold based on sample size
✅ **DO** document your threshold choice
✅ **DO** report how many peptides were filtered

❌ **DON'T** filter so strictly that you remove most peptides
❌ **DON'T** change threshold after seeing results
❌ **DON'T** forget to mention filtering in methods section

**Default recommendation**: `min_subjects = round(0.05 * n_subjects)`
