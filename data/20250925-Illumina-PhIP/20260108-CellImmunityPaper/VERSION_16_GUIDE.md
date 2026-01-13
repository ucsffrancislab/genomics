# Version 16 Updates - Technical Replicates & Enhanced Visualization

## Major Changes

### 1. Technical Replicate Handling ✓

**New Feature**: Collapse technical replicates by subject

**Conservative Approach**: ALL replicates must show enrichment for subject to be enriched

```python
pipeline.run_complete_pipeline(
    counts_file="counts.csv",
    peptide_metadata_file="peptide_metadata.csv",
    sample_metadata_file="sample_metadata.csv",  # MUST include subject_col
    output_dir="results",
    collapse_replicates=True,  # Enable replicate collapsing
    subject_col='subject_id'   # Column with subject IDs
)
```

**Sample Metadata Format**:
```csv
sample_id,subject_id,status,plate
sample_001,subject_A,case,plate1
sample_001_rep2,subject_A,case,plate1
sample_002,subject_B,control,plate1
sample_003,subject_C,case,plate2
sample_003_rep2,subject_C,case,plate2
sample_003_rep3,subject_C,case,plate2
```

**How it Works**:
- Groups samples by `subject_id`
- Takes MINIMUM across replicates (all must be 1 for subject to be 1)
- Reports: mean/min/max replicates per subject
- Final output: subjects × peptides (not samples × peptides)

### 2. Skip Protein/Virus Aggregation ✓

**New Parameter**: `skip_protein_virus=True`

For when you want peptide-level analysis only:

```python
results = pipeline.run_complete_pipeline(
    skip_protein_virus=True,  # Peptide-level only
    collapse_replicates=True,
    subject_col='subject_id',
    ...
)
```

**Advantages**:
- Faster (skips aggregation steps)
- Avoids threshold sensitivity issues
- Focus on individual epitopes
- Come back to protein/virus later when thresholds are calibrated

### 3. Enhanced Case-Control Visualizations

**New Plots Added**:

#### A. ROC Curve (Per-Peptide Classifier)
```python
analyzer.create_roc_curve(
    results_df=results['peptide'],
    top_n=10,  # Top 10 most significant peptides
    enriched_matrix=peptide_enriched,
    metadata=metadata,
    case_col='status',
    output_file='roc_curve.png'
)
```
- Shows diagnostic performance of top peptides
- AUC for each peptide
- Identifies best biomarkers

#### B. Venn Diagram (Case vs Control Overlap)
```python
analyzer.create_venn_diagram(
    enriched_matrix=peptide_enriched,
    metadata=metadata,
    case_col='status',
    output_file='venn_diagram.png'
)
```
- Shows peptide overlap between groups
- Case-specific, control-specific, shared
- Great for identifying unique signatures

#### C. Distribution Plot (Enrichment Patterns)
```python
analyzer.create_enrichment_distribution(
    enriched_matrix=peptide_enriched,
    metadata=metadata,
    case_col='status',
    output_file='enrichment_distribution.png'
)
```
- Histogram: number of enriched peptides per subject
- Compare distributions between cases/controls
- Identifies if cases have broader responses

#### D. Correlation Heatmap (Top Peptides)
```python
analyzer.create_peptide_correlation_heatmap(
    enriched_matrix=peptide_enriched,
    results_df=results['peptide'],
    top_n=50,
    output_file='peptide_correlations.png'
)
```
- Co-occurrence patterns of top peptides
- Identifies peptide clusters
- May reveal epitope spreading or cross-reactivity

#### E. Effect Size Plot (OR with CI)
```python
analyzer.create_effect_size_plot(
    results_df=results['peptide'],
    top_n=30,
    output_file='effect_sizes.png'
)
```
- Forest plot style
- Odds ratios with 95% CI
- Better than volcano for clinical interpretation

#### F. Cumulative Seroprevalence
```python
analyzer.create_cumulative_prevalence(
    enriched_matrix=peptide_enriched,
    metadata=metadata,
    results_df=results['peptide'],
    case_col='status',
    output_file='cumulative_prevalence.png'
)
```
- X-axis: peptides ranked by significance
- Y-axis: cumulative % of cases/controls seropositive
- Shows if top peptides capture most cases

## Updated CMV Test Script

```python
#!/usr/bin/env python3

from immunity_pipeline_complete import ImmunityPhIPSeqPipeline

pipeline = ImmunityPhIPSeqPipeline(
    rarefaction_depth=1_250_000,
    bonferroni_alpha=0.05,
    n_jobs=-1,
    # Don't need these if skip_protein_virus=True
    min_peptides_per_protein=5,
    min_proteins_per_virus=9
)

results = pipeline.run_complete_pipeline(
    counts_file="CMV_test/phipseq_counts_experimental_only.csv",
    peptide_metadata_file="peptide_metadata.csv",
    sample_metadata_file="CMV_test/sample_metadata.csv",
    output_dir="CMV_test/results",
    drop_low_depth=True,
    skip_protein_virus=True,  # NEW: Peptide-level only
    collapse_replicates=True,  # NEW: Handle replicates
    subject_col='subject_id'   # NEW: Subject ID column
)

print("\n" + "="*70)
print("PEPTIDE-LEVEL SUMMARY")
print("="*70)
print(f"Total subjects: {len(results['peptide_enriched'].columns)}")
print(f"Total peptides analyzed: {len(results['peptide_enriched'])}")
print(f"Mean peptides per subject: {results['peptide_enriched'].sum(axis=0).mean():.1f}")
```

## Updated Case-Control Script

```python
#!/usr/bin/env python3

from case_control_analysis import CaseControlAnalyzer
import pandas as pd

analyzer = CaseControlAnalyzer()

# Load data (now subjects, not samples)
peptide_enriched = pd.read_csv("CMV_test/results/peptide_enrichment_binary.csv", index_col=0)
metadata = pd.read_csv("CMV_test/sample_metadata.csv", index_col=0)

# Need to get one row per subject from metadata
# (after collapsing, metadata still has all samples)
metadata_subjects = metadata.groupby('subject_id').first()

# Run peptide-level analysis only
results = analyzer.test_single_entity(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    case_value='case',
    control_value='control'
)

# Apply FDR correction
results = analyzer.apply_fdr_correction(results)

# Save results
results.to_csv('CMV_test/results/case_control/peptide_results.csv', index=False)

print("\nCreating visualizations...")

# Original plots
analyzer.create_volcano_plot(
    results, 
    level_name='peptide',
    output_file='CMV_test/results/case_control/volcano_peptide.png'
)

analyzer.create_heatmap(
    peptide_enriched,
    metadata_subjects,
    results,
    top_n=50,
    output_file='CMV_test/results/case_control/heatmap_peptides.png'
)

# NEW PLOTS
analyzer.create_roc_curve(
    results,
    peptide_enriched,
    metadata_subjects,
    top_n=10,
    output_file='CMV_test/results/case_control/roc_curve.png'
)

analyzer.create_venn_diagram(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    output_file='CMV_test/results/case_control/venn_diagram.png'
)

analyzer.create_enrichment_distribution(
    peptide_enriched,
    metadata_subjects,
    case_col='status',
    output_file='CMV_test/results/case_control/enrichment_distribution.png'
)

analyzer.create_effect_size_plot(
    results,
    top_n=30,
    output_file='CMV_test/results/case_control/effect_sizes.png'
)

analyzer.create_cumulative_prevalence(
    peptide_enriched,
    metadata_subjects,
    results,
    case_col='status',
    output_file='CMV_test/results/case_control/cumulative_prevalence.png'
)

print("\nAnalysis complete!")
print(f"Total significant peptides (FDR < 0.05): {(results['fdr'] < 0.05).sum()}")
```

## Key Benefits

1. **Replicate Handling**: Conservative approach prevents false positives from technical variation
2. **Peptide Focus**: Avoid protein/virus threshold issues, get detailed epitope-level results
3. **Rich Visualization**: 7+ plots give comprehensive view of case-control differences
4. **Subject-Level**: Results are per biological subject, not technical replicate

## Implementation Notes

The updated files include:
- `immunity_pipeline_v16.py` - Pipeline with replicate handling and skip options
- `case_control_v16.py` - Analyzer with 6 new plot types
- `CMV_enrichment_v16.py` - Updated test script
- `CMV_case_control_v16.py` - Updated analysis script

All new plot methods follow the same pattern:
- Accept enriched_matrix, metadata, results_df
- Save high-res PNG
- Return matplotlib figure for customization
- Include clear labels and legends
