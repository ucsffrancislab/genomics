# PhIPSeq Analysis Pipeline - Complete Usage Guide

## Overview

This pipeline implements the Immunity 2023 (Andreu-Sánchez et al.) method for PhIPSeq analysis and provides seropositivity results at three levels:
- **Peptide level** - Individual peptide/tile seropositivity
- **Protein level** - Aggregated protein seropositivity  
- **Virus level** - Aggregated virus/organism seropositivity

---

## Quick Start

### 1. Install Dependencies

```bash
pip install pandas numpy scipy scikit-learn statsmodels matplotlib seaborn
```

### 2. Prepare Your Data Files

You need two input files:

#### A. Counts Matrix (`phipseq_counts.csv`)

Format: Peptides as rows, samples as columns

```csv
peptide_id,input_library,sample_001,sample_002,sample_003,...
pep_0001,1500,150,203,45,...
pep_0002,800,5,8,1200,...
pep_0003,2000,0,15,23,...
```

**Important:** 
- Include input library or beads-only column
- Column name should contain "input" or "beads" (case-insensitive)
- Or specify exact column name with `input_column` parameter

#### B. Peptide Metadata (`peptide_metadata.csv`)

Format: Annotations for each peptide

```csv
peptide_id,protein_name,organism,sequence,start_pos
pep_0001,VP1,EBV,MSLSKLAVAALITASA,1
pep_0002,VP1,EBV,ITASATTSGYSL,13
pep_0003,E7,HPV16,GDEVQMDIKNILEGVR,45
```

**Required columns:**
- `peptide_id` - Must match counts file
- `protein_name` - Protein identifier
- `organism` or `virus` - Organism/virus name

**Optional columns:**
- `sequence` - Amino acid sequence
- `start_pos` - Position in protein
- Any other annotations

---

## Usage Examples

### Example 1: Basic Pipeline (Seropositivity Only)

```python
from immunity_phipseq_pipeline import ImmunityPhIPSeqPipeline

# Initialize pipeline
pipeline = ImmunityPhIPSeqPipeline(
    rarefaction_depth=1_250_000,  # Default from paper
    bonferroni_alpha=0.05          # Significance threshold
)

# Run complete pipeline
results = pipeline.run_complete_pipeline(
    counts_file="phipseq_counts.csv",
    metadata_file="peptide_metadata.csv",
    output_dir="results"
)

# Access results
print(f"Enriched peptides: {len(results['peptide_enriched'])}")
print(f"Seropositive proteins: {len(results['protein_enriched'])}")
print(f"Seropositive viruses: {len(results['virus_enriched'])}")
```

**Outputs:**
- `results/peptide_enrichment_binary.csv` - Binary (0/1) enrichment matrix
- `results/protein_enrichment_binary.csv` - Protein-level aggregation
- `results/virus_enrichment_binary.csv` - Virus-level aggregation
- `results/peptide_pvalues.csv` - P-values for each peptide
- `results/peptide_seropositivity_stats.csv` - Prevalence statistics
- `results/protein_seropositivity_stats.csv`
- `results/virus_seropositivity_stats.csv`

### Example 2: Case-Control Analysis

```python
from immunity_phipseq_pipeline import ImmunityPhIPSeqPipeline
from case_control_analysis import CaseControlAnalyzer
import pandas as pd

# Step 1: Run pipeline to get seropositivity
pipeline = ImmunityPhIPSeqPipeline()
results = pipeline.run_complete_pipeline(
    counts_file="phipseq_counts.csv",
    metadata_file="peptide_metadata.csv",
    output_dir="results"
)

# Step 2: Load sample metadata with case/control labels
sample_metadata = pd.read_csv("sample_metadata.csv", index_col=0)
# Expected columns: sample_id, cancer_status (or disease_status), age, sex, etc.

# Step 3: Run case-control analysis
analyzer = CaseControlAnalyzer()
cc_results = analyzer.analyze_all_levels(
    peptide_enriched=results['peptide_enriched'],
    protein_enriched=results['protein_enriched'],
    virus_enriched=results['virus_enriched'],
    metadata=sample_metadata,
    case_col='cancer_status',     # Your case/control column name
    case_value='cancer',           # Value for cases
    control_value='healthy',       # Value for controls
    output_dir='results/case_control'
)

# View significant peptides
sig_peptides = cc_results['peptide'][cc_results['peptide']['fisher_qvalue'] < 0.05]
print(f"\nSignificant peptides: {len(sig_peptides)}")
print(sig_peptides.head(10))

# View significant viruses
sig_viruses = cc_results['virus'][cc_results['virus']['fisher_qvalue'] < 0.05]
print(f"\nSignificant viruses: {len(sig_viruses)}")
print(sig_viruses)
```

**Outputs:**
- `results/case_control/case_control_peptide.csv`
- `results/case_control/case_control_protein.csv`
- `results/case_control/case_control_virus.csv`
- Plus volcano plots and heatmaps

### Example 3: Creating Visualizations

```python
from case_control_analysis import CaseControlAnalyzer
import pandas as pd

# Load results
analyzer = CaseControlAnalyzer()
peptide_results = pd.read_csv("results/case_control/case_control_peptide.csv")
virus_results = pd.read_csv("results/case_control/case_control_virus.csv")
peptide_enriched = pd.read_csv("results/peptide_enrichment_binary.csv", index_col=0)
metadata = pd.read_csv("sample_metadata.csv", index_col=0)

# Create volcano plots
analyzer.create_volcano_plot(
    peptide_results,
    level_name='peptide',
    output_file='figures/volcano_peptides.png'
)

analyzer.create_volcano_plot(
    virus_results,
    level_name='virus',
    output_file='figures/volcano_viruses.png'
)

# Create heatmap of top peptides
analyzer.create_heatmap(
    peptide_enriched,
    metadata,
    peptide_results,
    top_n=50,
    output_file='figures/heatmap_top50_peptides.png'
)

# Create prevalence comparison
analyzer.create_prevalence_barplot(
    virus_results,
    top_n=20,
    level_name='virus',
    output_file='figures/prevalence_viruses.png'
)
```

---

## Step-by-Step Workflow

### Step 1: Prepare Data Files

Create or convert your existing data to the required formats:

```python
import pandas as pd

# If you have alignment output from Larman/Elledge pipeline
# Convert to required format

# Example: Convert from long format
alignment_data = pd.read_csv("alignment_output.txt", sep="\t")
counts_matrix = alignment_data.pivot_table(
    index='peptide_id',
    columns='sample_id',
    values='count',
    fill_value=0
)
counts_matrix.to_csv("phipseq_counts.csv")
```

### Step 2: Run Enrichment Calling

```python
from immunity_phipseq_pipeline import ImmunityPhIPSeqPipeline

pipeline = ImmunityPhIPSeqPipeline()

# Option A: Auto-detect input column
results = pipeline.run_complete_pipeline(
    counts_file="phipseq_counts.csv",
    metadata_file="peptide_metadata.csv",
    output_dir="results"
)

# Option B: Specify input column explicitly
results = pipeline.run_complete_pipeline(
    counts_file="phipseq_counts.csv",
    metadata_file="peptide_metadata.csv",
    output_dir="results",
    input_column="input_library_1"
)
```

### Step 3: Examine Seropositivity Results

```python
import pandas as pd

# Load results
peptide_stats = pd.read_csv("results/peptide_seropositivity_stats.csv")
protein_stats = pd.read_csv("results/protein_seropositivity_stats.csv")
virus_stats = pd.read_csv("results/virus_seropositivity_stats.csv")

# Most prevalent peptides
print("Top 10 most prevalent peptides:")
print(peptide_stats.head(10))

# Most prevalent viruses
print("\nTop 10 most prevalent viruses:")
print(virus_stats.head(10))

# Peptides with intermediate prevalence (5-95%)
mid_prev = peptide_stats[
    (peptide_stats['seroprevalence'] >= 0.05) & 
    (peptide_stats['seroprevalence'] <= 0.95)
]
print(f"\nPeptides with 5-95% prevalence: {len(mid_prev)}")
```

### Step 4: Case-Control Analysis

```python
from case_control_analysis import CaseControlAnalyzer
import pandas as pd

# Load enrichment matrices
peptide_enriched = pd.read_csv("results/peptide_enrichment_binary.csv", index_col=0)
protein_enriched = pd.read_csv("results/protein_enrichment_binary.csv", index_col=0)
virus_enriched = pd.read_csv("results/virus_enrichment_binary.csv", index_col=0)

# Load sample metadata
metadata = pd.read_csv("sample_metadata.csv", index_col=0)

# Run analysis
analyzer = CaseControlAnalyzer()
cc_results = analyzer.analyze_all_levels(
    peptide_enriched,
    protein_enriched,
    virus_enriched,
    metadata,
    case_col='disease_status',
    case_value='cancer',
    control_value='healthy',
    output_dir='results/case_control'
)

# Extract significant findings
sig_peptides = cc_results['peptide'][cc_results['peptide']['fisher_qvalue'] < 0.05]
sig_proteins = cc_results['protein'][cc_results['protein']['fisher_qvalue'] < 0.05]
sig_viruses = cc_results['virus'][cc_results['virus']['fisher_qvalue'] < 0.05]

print(f"\nSignificant entities (FDR < 0.05):")
print(f"  Peptides: {len(sig_peptides)}")
print(f"  Proteins: {len(sig_proteins)}")
print(f"  Viruses: {len(sig_viruses)}")

# Most significant virus
if len(sig_viruses) > 0:
    top_virus = sig_viruses.iloc[0]
    print(f"\nTop virus: {top_virus['entity_id']}")
    print(f"  Odds ratio: {top_virus['odds_ratio']:.2f}")
    print(f"  P-value: {top_virus['fisher_pvalue']:.2e}")
    print(f"  Case prevalence: {top_virus['case_prevalence']:.1%}")
    print(f"  Control prevalence: {top_virus['control_prevalence']:.1%}")
```

---

## Understanding the Outputs

### Binary Enrichment Matrix

Format: Rows = peptides/proteins/viruses, Columns = samples, Values = 0 or 1

```csv
entity_id,sample_001,sample_002,sample_003,...
pep_0001,1,1,0,...
pep_0002,0,0,1,...
```

- `1` = Seropositive (enriched)
- `0` = Seronegative (not enriched)

### Seropositivity Statistics

```csv
peptide_id,n_positive_samples,n_total_samples,seroprevalence
pep_0001,45,100,0.45
pep_0002,8,100,0.08
```

- `seroprevalence` = proportion of samples that are seropositive

### Case-Control Results

```csv
entity_id,case_positive,case_total,control_positive,control_total,odds_ratio,fisher_pvalue,fisher_qvalue
virus_EBV,35,50,12,50,5.42,0.0001,0.002
```

Key columns:
- `odds_ratio` - Odds of seropositivity in cases vs controls
- `fisher_pvalue` - Fisher's exact test p-value
- `fisher_qvalue` - FDR-corrected q-value

---

## Parameter Tuning

### Rarefaction Depth

Default: 1,250,000 reads (from Immunity 2023 paper)

```python
# Adjust if your samples have different read depths
pipeline = ImmunityPhIPSeqPipeline(rarefaction_depth=500_000)
```

Considerations:
- Lower depth = less power to detect enrichment
- Higher depth = need sufficient reads in all samples
- Check total reads per sample first

### Bonferroni Threshold

Default: 0.05

```python
# More stringent
pipeline = ImmunityPhIPSeqPipeline(bonferroni_alpha=0.01)

# More permissive
pipeline = ImmunityPhIPSeqPipeline(bonferroni_alpha=0.10)
```

### Prevalence Filtering

Default: Keep peptides with 5-95% prevalence

```python
# Custom filtering
filtered = pipeline.filter_peptides(
    enriched,
    min_prevalence=0.10,  # More stringent
    max_prevalence=0.90
)
```

---

## Troubleshooting

### Issue: No input library column found

**Error:** `ValueError: Could not find input library column`

**Solution:** Specify column explicitly
```python
results = pipeline.run_complete_pipeline(
    counts_file="phipseq_counts.csv",
    metadata_file="peptide_metadata.csv",
    output_dir="results",
    input_column="beads_only_sample_1"
)
```

### Issue: Sample has fewer reads than rarefaction target

**Warning:** `Warning: sample_X has only 800,000 reads (below target)`

**Solution:** Either:
1. Lower rarefaction depth:
```python
pipeline = ImmunityPhIPSeqPipeline(rarefaction_depth=500_000)
```

2. Remove low-depth samples from counts file

### Issue: Missing metadata columns

**Error:** `KeyError: 'protein_name'`

**Solution:** Check your peptide metadata has required columns. Rename if needed:
```python
metadata = pd.read_csv("peptide_metadata.csv")
metadata.rename(columns={'Protein': 'protein_name', 'Virus': 'organism'}, inplace=True)
metadata.to_csv("peptide_metadata_fixed.csv", index=False)
```

### Issue: Memory errors with large datasets

**Solution:** Process in batches or use data types efficiently:
```python
# Load counts with efficient dtypes
counts = pd.read_csv("phipseq_counts.csv", dtype={'peptide_id': str, 'input': 'int32'})
```

---

## Expected Runtime

Typical runtimes on a modern laptop:

- 10,000 peptides × 100 samples: ~2-5 minutes
- 100,000 peptides × 100 samples: ~20-30 minutes
- 100,000 peptides × 1000 samples: ~2-3 hours

Bottleneck: Fitting Generalized Poisson model for each sample

---

## Citation

If you use this pipeline, please cite:

> Andreu-Sánchez S, Bourgonje AR, Vogl T, et al. Phage display sequencing reveals that genetic, environmental, and intrinsic factors influence variation of human antibody epitope repertoire. Immunity. 2023;56(6):1376-1392.e8.

---

## Support

For issues or questions:
1. Check this README
2. Review the code comments
3. Try the examples above
4. Check original paper methods section

---

## Complete Example Script

```python
#!/usr/bin/env python3
"""
Complete PhIPSeq analysis workflow
"""

from immunity_phipseq_pipeline import ImmunityPhIPSeqPipeline
from case_control_analysis import CaseControlAnalyzer
import pandas as pd

def main():
    print("Starting PhIPSeq analysis...")
    
    # Step 1: Run enrichment pipeline
    print("\n" + "="*70)
    print("STEP 1: Enrichment Calling")
    print("="*70)
    
    pipeline = ImmunityPhIPSeqPipeline()
    results = pipeline.run_complete_pipeline(
        counts_file="data/phipseq_counts.csv",
        metadata_file="data/peptide_metadata.csv",
        output_dir="results"
    )
    
    # Step 2: Case-control analysis
    print("\n" + "="*70)
    print("STEP 2: Case-Control Analysis")
    print("="*70)
    
    sample_metadata = pd.read_csv("data/sample_metadata.csv", index_col=0)
    
    analyzer = CaseControlAnalyzer()
    cc_results = analyzer.analyze_all_levels(
        peptide_enriched=results['peptide_enriched'],
        protein_enriched=results['protein_enriched'],
        virus_enriched=results['virus_enriched'],
        metadata=sample_metadata,
        case_col='cancer_status',
        case_value='case',
        control_value='control',
        output_dir='results/case_control'
    )
    
    # Step 3: Create visualizations
    print("\n" + "="*70)
    print("STEP 3: Creating Visualizations")
    print("="*70)
    
    analyzer.create_volcano_plot(
        cc_results['peptide'],
        level_name='peptide',
        output_file='results/case_control/volcano_peptide.png'
    )
    
    analyzer.create_volcano_plot(
        cc_results['virus'],
        level_name='virus',
        output_file='results/case_control/volcano_virus.png'
    )
    
    analyzer.create_heatmap(
        results['peptide_enriched'],
        sample_metadata,
        cc_results['peptide'],
        top_n=50,
        output_file='results/case_control/heatmap_peptides.png'
    )
    
    # Step 4: Summary report
    print("\n" + "="*70)
    print("FINAL SUMMARY")
    print("="*70)
    
    print(f"\nEnrichment results:")
    print(f"  Enriched peptides: {len(results['peptide_enriched'])}")
    print(f"  Seropositive proteins: {len(results['protein_enriched'])}")
    print(f"  Seropositive viruses: {len(results['virus_enriched'])}")
    
    print(f"\nCase-control results (FDR < 0.05):")
    print(f"  Significant peptides: {(cc_results['peptide']['fisher_qvalue'] < 0.05).sum()}")
    print(f"  Significant proteins: {(cc_results['protein']['fisher_qvalue'] < 0.05).sum()}")
    print(f"  Significant viruses: {(cc_results['virus']['fisher_qvalue'] < 0.05).sum()}")
    
    print("\nAll results saved to results/")
    print("Analysis complete!")

if __name__ == "__main__":
    main()
```

Save as `run_phipseq_analysis.py` and run:
```bash
python run_phipseq_analysis.py
```
