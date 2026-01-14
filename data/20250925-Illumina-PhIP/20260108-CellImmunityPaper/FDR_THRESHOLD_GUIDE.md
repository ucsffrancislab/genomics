# FDR Threshold Selection Guide

## What is FDR?

**FDR (False Discovery Rate)** controls the expected proportion of false positives among your significant results.

- **FDR = 0.05** means you expect ~5% of your "significant" findings to be false positives
- Unlike Bonferroni (which controls family-wise error), FDR is less conservative
- FDR is the standard for high-dimensional data like PhIPSeq (100K+ tests)

---

## Standard FDR Thresholds

### FDR = 0.05 (Standard, Recommended Default)
**Use for**: Publication-quality findings, validated discoveries

**Interpretation**: "I'm willing to accept that 5% of my significant peptides might be false positives"

**When to use**:
- Final analysis for publication
- High-confidence biomarker discovery
- Clinical validation studies
- Known positive controls (like your CMV dataset)

**Example**: With 1000 significant peptides at FDR < 0.05, expect ~50 false positives

---

### FDR = 0.10 (Exploratory)
**Use for**: Hypothesis generation, preliminary screening

**Interpretation**: "I'm willing to accept that 10% of my significant peptides might be false positives"

**When to use**:
- Initial exploratory analysis
- Screening for interesting patterns
- When you'll validate findings later
- Small sample sizes with limited power
- Datasets with no expected strong signals

**Example**: Your Glioma dataset with 0 significant at FDR < 0.05 might have interesting signals at FDR < 0.10

**Trade-off**: More discoveries, but lower confidence

---

### FDR = 0.01 (Stringent)
**Use for**: High-confidence discoveries, avoiding false positives

**Interpretation**: "I only want findings where I expect ≤1% false positives"

**When to use**:
- Strong signal expected (e.g., vaccine response)
- When false positives are very costly
- Follow-up validation is expensive
- Publishing in high-impact journals
- Regulatory submissions

**Trade-off**: Fewer discoveries, may miss true positives

---

## Is Adjusting FDR "Bad Science"?

### **No, it's not bad science IF done correctly:**

### ✅ GOOD Practice:
1. **Pre-specify your threshold** before seeing results
2. **Document your choice** and rationale
3. **Report multiple thresholds** in supplementary materials
4. **Use standard thresholds** (0.01, 0.05, 0.10)
5. **Be transparent** about exploratory vs confirmatory

### ❌ BAD Practice:
1. **P-hacking**: Trying multiple thresholds until you get "significant" results
2. **Selective reporting**: Only reporting the threshold that gives desired results
3. **Post-hoc justification**: Choosing threshold after seeing results
4. **Arbitrary thresholds**: Using 0.073 or other non-standard values
5. **Not reporting**: Failing to state what threshold was used

---

## How to Use in Your Analysis

### Standard Analysis (CMV-like dataset):
```python
# Use standard 0.05 threshold
results = analyzer.apply_fdr_correction(results, fdr_threshold=0.05)
```

### Exploratory Analysis (Glioma-like dataset):
```python
# Try exploratory threshold
results = analyzer.apply_fdr_correction(results, fdr_threshold=0.10)

# Report in paper:
# "Given the exploratory nature of this analysis and limited sample size,
#  we used FDR < 0.10 to identify candidate biomarkers for future validation."
```

### Stringent Analysis (Vaccine response):
```python
# Use stringent threshold
results = analyzer.apply_fdr_correction(results, fdr_threshold=0.01)
```

### Multi-threshold Reporting (Best practice):
```python
# Calculate all thresholds
results_fdr01 = analyzer.apply_fdr_correction(results.copy(), fdr_threshold=0.01)
results_fdr05 = analyzer.apply_fdr_correction(results.copy(), fdr_threshold=0.05)
results_fdr10 = analyzer.apply_fdr_correction(results.copy(), fdr_threshold=0.10)

# Report in paper:
# "We identified 50 peptides at FDR < 0.01, 234 at FDR < 0.05, 
#  and 567 at FDR < 0.10 (Supplementary Table X)."
```

---

## Your Glioma Dataset

Your results show:
```
Significant (p < 0.05): 1894
Significant (FDR < 0.05): 0
```

This means:
- 1894 peptides have **nominal** p-value < 0.05
- But after FDR correction, **none** survive at FDR < 0.05
- This suggests: weak signals, small effect sizes, or insufficient power

### Options:

**Option 1: Use FDR = 0.10 (Recommended for exploration)**
```python
results = analyzer.apply_fdr_correction(results, fdr_threshold=0.10)
```
- Will likely identify some peptides
- Reasonable for exploratory analysis
- Plan to validate top hits in future studies

**Option 2: Focus on Top Ranked Peptides**
```python
# Look at top 50 by p-value regardless of FDR
top_candidates = results.nsmallest(50, 'fisher_pvalue')
```
- Treat as candidate list for validation
- Don't claim "significance"
- Use language like "suggestive" or "nominally significant"

**Option 3: Report Honestly**
```
"No peptides reached genome-wide significance at FDR < 0.05, 
 suggesting limited peptide-level differences between glioma 
 cases and controls in this cohort. The top-ranked peptides 
 (Supplementary Table X) may warrant follow-up in larger studies."
```

---

## Sample Size Considerations

Your datasets:
- **CMV**: 47 subjects (22 cases, 25 controls) → Strong signal expected → Use FDR = 0.05
- **Glioma**: 215 subjects (110 cases, 105 controls) → Weak signal → Consider FDR = 0.10

**Larger sample size ≠ lower FDR threshold needed**
- FDR controls false discoveries, not power
- Large samples with weak effects: Still use standard FDR = 0.05
- Small samples with strong effects: Can use stringent FDR = 0.01

---

## Field-Specific Norms

### Genomics/Proteomics:
- Standard: FDR = 0.05
- Common to report: FDR = 0.01, 0.05, 0.10

### Neuroscience/Psychology:
- Often more lenient: FDR = 0.10 common
- Multiple comparison correction sometimes skipped (controversial)

### Clinical Trials:
- Very stringent: Often Bonferroni correction
- Or FDR = 0.01 for secondary endpoints

### Machine Learning/AI:
- Often no FDR correction
- Focus on cross-validation, held-out test sets

**Bottom line**: Follow norms in your field, but FDR = 0.05 is universally acceptable

---

## Reporting Template

### For Papers:

**Methods Section:**
```
Statistical significance was assessed using Fisher's exact test with 
False Discovery Rate (FDR) correction via the Benjamini-Hochberg procedure. 
We used FDR < 0.05 as our significance threshold [or: 0.10 for exploratory 
analyses]. All statistical tests were two-sided.
```

**Results Section:**
```
We identified X peptides significantly associated with [condition] at 
FDR < 0.05 (Supplementary Table X). The top-ranked peptide (ID: XXXXX) 
showed [prevalence/odds ratio] with FDR-corrected p-value = X.XX × 10^-X.
```

**If no significant findings:**
```
No peptides reached significance at FDR < 0.05. However, X peptides showed 
nominal significance (p < 0.05), with the top candidates showing [pattern]. 
These findings suggest [interpretation] and warrant validation in larger cohorts.
```

---

## Key Takeaways

1. ✅ **FDR = 0.05 is the standard** - use this by default
2. ✅ **FDR = 0.10 is reasonable** for exploratory analyses
3. ✅ **FDR = 0.01 is appropriate** when you need high confidence
4. ✅ **Pre-specify your threshold** before analysis
5. ✅ **Report multiple thresholds** in supplementary materials
6. ✅ **Be transparent** about exploratory vs confirmatory
7. ❌ **Don't p-hack** by trying thresholds until you get significance
8. ❌ **Don't use arbitrary values** like 0.073 or 0.12

**The key is transparency and scientific rigor, not the specific threshold you choose.**
