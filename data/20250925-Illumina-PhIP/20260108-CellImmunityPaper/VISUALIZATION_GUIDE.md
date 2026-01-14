# PhIPSeq Case-Control Visualization Suite

## Overview
The updated case-control analyzer now generates **13 different visualizations** to comprehensively explore peptide-level differences between cases and controls.

---

## Plot Descriptions

### 1. **Volcano Plot** (`volcano_peptide.png`)
**Purpose**: Identify statistically significant peptides with large effect sizes

**What it shows**:
- X-axis: Log2 fold change (prevalence difference)
- Y-axis: -log10(p-value)
- Points colored by significance threshold

**Interpretation**:
- Top-right: Enriched in cases (significant)
- Top-left: Enriched in controls (significant)
- Top: Highly significant but small effect
- Right: Large effect but not significant

---

### 2. **Clustered Heatmap** (`heatmap_peptides.png`)
**Purpose**: Visualize patterns of enrichment across subjects

**What it shows**:
- Rows: Top 50 most significant peptides
- Columns: Individual subjects (grouped by case/control)
- Colors: Red = enriched, Blue = not enriched
- Dendrograms: Hierarchical clustering

**Interpretation**:
- Clusters of peptides that co-occur
- Subjects with similar immune profiles
- Case vs control enrichment patterns

---

### 3. **Enrichment Distribution** (`enrichment_distribution.png`)
**Purpose**: Compare overall immune response breadth between groups

**What it shows**:
- Histogram of number of enriched peptides per subject
- Overlaid distributions for cases (red) and controls (blue)
- Mean lines for each group

**Interpretation**:
- Do cases have broader responses (more peptides)?
- Is there a bimodal distribution (responders vs non-responders)?
- Overlap suggests similar immune profiles

---

### 4. **Prevalence Bar Plot** (`prevalence_peptides.png`)
**Purpose**: Show seroprevalence of top peptides

**What it shows**:
- Top 20 most significant peptides
- Bars showing % of cases and controls seropositive

**Interpretation**:
- Which peptides are most prevalent in cases?
- Case-specific vs shared peptides
- Potential diagnostic markers

---

### 5. **ROC Curves** (`roc_curve.png`)
**Purpose**: Evaluate diagnostic performance of individual peptides

**What it shows**:
- ROC curves for top 10 peptides
- AUC (Area Under Curve) for each
- Diagonal = random classifier (AUC = 0.5)

**Interpretation**:
- AUC > 0.7: Good biomarker
- AUC > 0.8: Strong biomarker
- AUC > 0.9: Excellent biomarker
- Compare peptides' predictive power

---

### 6. **Venn Diagram** (`venn_diagram.png`)
**Purpose**: Show overlap in peptide repertoires between groups

**What it shows**:
- Circle for cases: peptides enriched in ≥1 case
- Circle for controls: peptides enriched in ≥1 control
- Overlap: peptides enriched in both groups

**Interpretation**:
- Case-specific peptides (left only)
- Control-specific peptides (right only)
- Shared peptides (overlap)
- Relative sizes indicate group differences

---

### 7. **Effect Size Plot / Forest Plot** (`effect_sizes.png`)
**Purpose**: Show odds ratios with confidence intervals

**What it shows**:
- Top 30 peptides ranked by significance
- Odds ratios (OR) on log scale
- 95% confidence intervals (error bars)
- Red line at OR = 1 (no effect)

**Interpretation**:
- OR > 1: Higher odds in cases
- OR < 1: Higher odds in controls
- Wide CI: Uncertain estimate
- Narrow CI: Precise estimate
- CI crossing 1: Not significant

---

### 8. **Cumulative Prevalence** (`cumulative_prevalence.png`)
**Purpose**: Show how many subjects are captured by top peptides

**What it shows**:
- X-axis: Number of top peptides (ranked by p-value)
- Y-axis: % of subjects seropositive for ≥1 of those peptides
- Separate curves for cases (red) and controls (blue)

**Interpretation**:
- Steep initial rise: Few peptides capture most subjects
- Plateau: Adding more peptides doesn't help
- Gap between curves: Diagnostic potential
- Use to decide how many peptides needed for a panel

---

### 9. **Violin Plot** (`violin_plot.png`)
**Purpose**: Compare peptide count distributions with statistical detail

**What it shows**:
- Violin shapes: Density of peptide counts
- Box plot inside: Median, quartiles
- Individual points: Each subject
- T-test p-value at top

**Interpretation**:
- Width of violin: How common that count is
- Median comparison: Central tendency difference
- Distribution shape: Unimodal, bimodal, skewed?
- Outliers visible as individual points

---

### 10. **Peptide Correlation Heatmap** (`peptide_correlations.png`)
**Purpose**: Identify peptides that co-occur (potential epitope spreading)

**What it shows**:
- Top 50 most significant peptides
- Correlation matrix (peptide × peptide)
- Red = positive correlation, Blue = negative

**Interpretation**:
- Clusters of correlated peptides: Same protein? Related viruses?
- Strong correlations (r > 0.7): Co-occurring responses
- May indicate:
  - Epitope spreading
  - Cross-reactive antibodies
  - Common exposure patterns

---

### 11. **Manhattan Plot** (`manhattan_plot.png`)
**Purpose**: Genome-wide view of all peptide significance

**What it shows**:
- X-axis: All peptides in order
- Y-axis: -log10(p-value)
- Alternating colors for visual grouping
- Threshold lines (Bonferroni, FDR)

**Interpretation**:
- Peaks: Significant peptides
- Above red line: Bonferroni significant (very stringent)
- Above green line: FDR significant (standard)
- Broad pattern of significance vs isolated peaks

---

### 12. **Prevalence Comparison** (`prevalence_comparison.png`)
**Purpose**: Side-by-side comparison of case vs control prevalence

**What it shows**:
- Top 30 peptides
- Side-by-side bars for case (red) and control (blue) prevalence
- Easier to compare than stacked bars

**Interpretation**:
- Large gaps: Strong case-control differences
- Similar bars: High background prevalence
- Peptides with high case prevalence + low control prevalence = best biomarkers

---

### 13. **UpSet Plot** (`upset_plot.png`)
**Purpose**: Show combinations of peptides in individual subjects

**What it shows**:
- Bottom: Set membership matrix (which peptides)
- Top: Bar chart (how many subjects have that combination)
- More powerful than Venn for >3 sets

**Interpretation**:
- Common combinations of peptides
- Subjects with identical immune signatures
- Unique vs shared response patterns
- Most informative for identifying peptide panels

**Note**: Requires `upsetplot` package. If not installed, this plot is skipped.

---

## Recommended Analysis Workflow

### Step 1: Overview
Start with these to get the big picture:
- **Volcano plot**: Which peptides are significant?
- **Manhattan plot**: Overall pattern of significance
- **Venn diagram**: How different are cases vs controls?

### Step 2: Group Differences
Understand case-control differences:
- **Enrichment distribution**: Overall response breadth
- **Violin plot**: Statistical comparison of counts
- **Prevalence comparison**: Top peptides side-by-side

### Step 3: Top Peptides
Focus on most significant findings:
- **Heatmap**: Clustering patterns
- **ROC curves**: Diagnostic performance
- **Effect sizes**: Odds ratios with confidence

### Step 4: Response Patterns
Understand immune response structure:
- **Peptide correlations**: Co-occurring peptides
- **Cumulative prevalence**: Panel optimization
- **UpSet plot**: Combination patterns

---

## Customization Options

All plot functions accept parameters for customization:

```python
# Change number of top peptides
analyzer.create_roc_curve(results, enriched, metadata, top_n=20)  # Show 20 instead of 10

# Modify output resolution
analyzer.create_volcano_plot(results, output_file='volcano.png', dpi=600)  # Higher quality

# Filter by specific peptides
cmv_results = results[results['entity_id'].str.contains('CMV')]
analyzer.create_effect_size_plot(cmv_results, top_n=50)
```

---

## Interpreting Your CMV Data

Given that you have known CMV+ vs CMV- subjects:

### Expected Patterns:

1. **Volcano plot**: CMV peptides should be in top-right (significant + enriched in cases)

2. **ROC curves**: CMV peptides should have AUC > 0.8

3. **Venn diagram**: CMV peptides mostly in "Cases only" region

4. **Cumulative prevalence**: Steep rise in cases, flat in controls for CMV peptides

5. **Heatmap**: Clear separation between cases and controls based on CMV peptides

6. **Correlation heatmap**: CMV peptides should cluster together (from same virus)

### Red Flags:

- **No separation in violin plot**: Groups are too similar
- **AUC near 0.5 in ROC**: Peptides can't discriminate
- **Large Venn overlap**: Not enough case-specific peptides
- **Flat cumulative curve**: Top peptides don't capture subjects

---

## Performance Notes

**Fast plots** (< 1 second):
- Volcano plot
- Enrichment distribution
- Violin plot
- Venn diagram
- Manhattan plot

**Medium plots** (1-10 seconds):
- Heatmap (depends on clustering)
- ROC curves
- Prevalence plots
- Effect sizes

**Slow plots** (10-60 seconds):
- Peptide correlations (50×50 matrix)
- Cumulative prevalence (iterates through peptides)
- UpSet plot (complex combinations)

For very large datasets (>1M peptides), consider:
- Filtering to top 1000 before correlation heatmap
- Limiting cumulative prevalence to top 1000 peptides
- Reducing top_n parameter

---

## Required Packages

All plots work with standard packages:
```bash
pip install pandas numpy scipy matplotlib seaborn scikit-learn statsmodels
```

Optional packages:
```bash
pip install matplotlib-venn  # For Venn diagrams
pip install upsetplot        # For UpSet plots
```

---

## Troubleshooting

**"Module not found: matplotlib_venn"**
→ `pip install matplotlib-venn`

**"Module not found: upsetplot"**
→ Skips UpSet plot automatically, install if needed

**Heatmap too crowded**
→ Reduce `top_n` parameter

**ROC plot legend overlaps**
→ Reduce `top_n` or manually adjust legend position

**Correlation heatmap labels unreadable**
→ Reduce `top_n` to 30 or fewer peptides

**Plots saving to wrong location**
→ Check `output_file` path includes full directory

---

## Citation

When publishing, cite appropriate methods:

- **Fisher's exact test**: Fisher, R.A. (1922)
- **FDR correction**: Benjamini & Hochberg (1995)
- **ROC curves**: Hanley & McNeil (1982)
- **Hierarchical clustering**: Ward (1963)
- **UpSet plots**: Lex et al. (2014)

For PhIPSeq-specific citations, see the main pipeline documentation.
