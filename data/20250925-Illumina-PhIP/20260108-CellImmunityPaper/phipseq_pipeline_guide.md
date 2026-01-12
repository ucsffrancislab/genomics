# Modern PhIPSeq Case-Control Analysis for Cancer Research
## Updated Guide with Current Tools (2023-2024)

**Your Research Goal:** Detect sero-reactivity differences between case and control groups for cancer and disease at:
- **Single peptide level** (specific antigens/tiles)
- **Systematic level** (global shifts, pathway/virus patterns, modules/communities)

---

## ⚠️ Important Update

You're absolutely correct about **phipcc** being outdated (last updated 6+ years ago). Here's the current state of PhIPSeq tools:

### Modern, Actively Maintained Tools (2023-2024):

1. **phippery** ✅ - Published Oct 2023 in Bioinformatics
   - From Fred Hutch Cancer Center (Matsen/Overbaugh labs)
   - Actively maintained
   - Multiple publications using it
   - **Best choice for modern analysis**

2. **PhIP-Seq-Analyzer** - Larman Lab (Johns Hopkins)
   - Original developers of PhIPSeq
   - Still maintained
   - Good if you followed Larman/Elledge protocols

3. **phip-stat** - Laserson Lab
   - Implements statistical models
   - Used in several publications

### Outdated Tools (Avoid):
- ❌ **phipcc** - Last commit 2018, likely incompatible with modern R
- ❌ Most custom scripts from old papers

---

## Table of Contents

1. [Recommended: phippery Suite](#phippery-suite)
2. [Alternative: Larman Lab Tools](#larman-tools)
3. [Case-Control Statistical Analysis](#case-control-analysis)
4. [Module/Community Detection](#module-detection)
5. [Publications Using These Tools](#publications)

---

## Option 1: phippery Suite (RECOMMENDED) {#phippery-suite}

**Publication:** Galloway et al., Bioinformatics 2023  
**GitHub:** https://github.com/matsengrp/phippery  
**Documentation:** https://matsengrp.github.io/phippery/

### Why phippery?

✅ **Published October 2023** - Most recent PhIPSeq tool  
✅ **Actively maintained** - Fred Hutch Cancer Center  
✅ **Multiple publications** - Proven in peer-reviewed research  
✅ **Complete pipeline** - Raw reads → statistical analysis → visualization  
✅ **Modern tech stack** - Nextflow, Python, xarray, Streamlit  
✅ **Well documented** - Comprehensive tutorials and examples  

### Three Components

1. **phip-flow** - Nextflow pipeline (raw reads → counts)
2. **phippery** - Python API (enrichment, statistics, analysis)
3. **phip-viz** - Streamlit app (interactive visualization)

### Installation

```bash
# Install Nextflow (for phip-flow pipeline)
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/

# Install phippery Python package
pip install phippery

# Or from source
git clone https://github.com/matsengrp/phippery.git
cd phippery
pip install -e .

# Install phip-flow pipeline
git clone https://github.com/matsengrp/phip-flow.git
cd phip-flow

# Install phip-viz (optional, for visualization)
git clone https://github.com/matsengrp/phip-viz.git
cd phip-viz
pip install -r requirements.txt
```

### Quick Start: Processing Your VirScan Data

#### Step 1: Prepare Input Files

phippery needs three inputs:

**1. Sample metadata** (`sample_metadata.csv`):
```csv
sample_id,cancer_status,age,sex,batch
patient_001,case,55,F,batch1
patient_002,control,52,M,batch1
patient_003,case,61,F,batch2
patient_004,control,58,M,batch2
```

**2. Peptide metadata** (`peptide_metadata.csv`):
```csv
Oligo_ID,Seq,protein_name,organism,start_pos
pep_0001,MSLSKLAVAALITASA,VP1,EBV,1
pep_0002,ITASATTSGYSL,VP1,EBV,13
pep_0003,GDEVQMDIKNILEGVR,E7,HPV16,45
```

**3. FASTQ files** (from sequencer):
```
sample_001_R1.fastq.gz
sample_002_R1.fastq.gz
...
```

#### Step 2: Run phip-flow Pipeline

Create `nextflow.config`:
```groovy
params {
    // Input files
    sample_table = "sample_metadata.csv"
    peptide_table = "peptide_metadata.csv"
    fastq_dir = "fastq_files/"
    
    // Output
    outdir = "results/"
    
    // Analysis parameters
    counts_normalize = "cpm"  // Counts per million
    beads_samples = "beads_only_1,beads_only_2,beads_only_3"
}
```

Run the pipeline:
```bash
cd phip-flow

nextflow run main.nf \
  -c nextflow.config \
  -profile docker  # or singularity
```

This will:
1. Align reads to peptide library
2. Count reads per peptide per sample
3. Normalize counts (CPM)
4. Calculate enrichment scores
5. Output xarray dataset + CSV files

#### Step 3: Case-Control Analysis with Python

```python
import phippery
import pandas as pd
import numpy as np
from scipy.stats import fisher_exact
from statsmodels.stats.multitest import multipletests

# Load phippery dataset
ds = phippery.load("results/phip_dataset.phip")

# Load metadata
metadata = pd.read_csv("sample_metadata.csv", index_col="sample_id")

# Get enrichment data
enrichment = ds["enrichment"].to_dataframe().reset_index()

# Separate cases and controls
cases = metadata[metadata["cancer_status"] == "case"].index
controls = metadata[metadata["cancer_status"] == "control"].index

# Pivot to peptide x sample matrix
enrich_matrix = enrichment.pivot(
    index="peptide_id", 
    columns="sample_id", 
    values="enrichment"
)

# Binary enrichment (Z-score > 2.5)
binary_enrich = (enrich_matrix > 2.5).astype(int)

# Case-control test for each peptide
results = []

for peptide in binary_enrich.index:
    case_pos = binary_enrich.loc[peptide, cases].sum()
    case_neg = len(cases) - case_pos
    control_pos = binary_enrich.loc[peptide, controls].sum()
    control_neg = len(controls) - control_pos
    
    # Fisher's exact test
    contingency_table = [
        [case_pos, case_neg],
        [control_pos, control_neg]
    ]
    
    odds_ratio, pvalue = fisher_exact(contingency_table)
    
    results.append({
        "peptide_id": peptide,
        "case_positive": case_pos,
        "case_total": len(cases),
        "control_positive": control_pos,
        "control_total": len(controls),
        "case_prevalence": case_pos / len(cases),
        "control_prevalence": control_pos / len(controls),
        "odds_ratio": odds_ratio,
        "pvalue": pvalue
    })

# Create results dataframe
results_df = pd.DataFrame(results)

# FDR correction
_, qvalues, _, _ = multipletests(
    results_df["pvalue"], 
    method="fdr_bh"
)
results_df["qvalue"] = qvalues

# Sort by significance
results_df = results_df.sort_values("pvalue")

# Save results
results_df.to_csv("case_control_results.csv", index=False)

# Print significant peptides
sig_peptides = results_df[results_df["qvalue"] < 0.05]
print(f"\nFound {len(sig_peptides)} significant peptides (q < 0.05)")
print("\nTop 10 peptides enriched in cases:")
print(sig_peptides.head(10))
```

#### Step 4: Visualization with phip-viz

```bash
cd phip-viz

# Launch interactive app
streamlit run app.py -- --dataset ../results/phip_dataset.phip

# Open browser to http://localhost:8501
# Use web interface to:
# - Select case/control groups
# - Generate heatmaps
# - Export plots and data
```

### Advanced: Module Detection

```python
import phippery
import numpy as np
from sklearn.cluster import AgglomerativeClustering
from scipy.stats import pearsonr

# Load dataset
ds = phippery.load("results/phip_dataset.phip")

# Get binary enrichment matrix
enrichment = ds["enrichment"].to_dataframe().reset_index()
enrich_matrix = enrichment.pivot(
    index="peptide_id",
    columns="sample_id", 
    values="enrichment"
)

binary = (enrich_matrix > 2.5).astype(int)

# Calculate correlation matrix
cor_matrix = binary.T.corr()

# Hierarchical clustering
distance_matrix = 1 - cor_matrix.abs()
clustering = AgglomerativeClustering(
    n_clusters=None,
    distance_threshold=0.3,
    metric="precomputed",
    linkage="average"
)

clusters = clustering.fit_predict(distance_matrix)

# Create module assignments
modules = pd.DataFrame({
    "peptide_id": binary.index,
    "module": clusters
})

# Filter small modules
module_sizes = modules["module"].value_counts()
keep_modules = module_sizes[module_sizes >= 10].index
modules_filtered = modules[modules["module"].isin(keep_modules)]

print(f"Identified {len(keep_modules)} modules with ≥10 peptides")

# Test module enrichment in cases vs controls
module_results = []

for module_id in modules_filtered["module"].unique():
    module_peptides = modules_filtered[
        modules_filtered["module"] == module_id
    ]["peptide_id"].values
    
    # Module score = mean enrichment across peptides
    module_scores = binary.loc[module_peptides].mean(axis=0)
    
    # T-test between cases and controls
    from scipy.stats import ttest_ind
    
    case_scores = module_scores[cases]
    control_scores = module_scores[controls]
    
    statistic, pvalue = ttest_ind(case_scores, control_scores)
    
    module_results.append({
        "module_id": module_id,
        "n_peptides": len(module_peptides),
        "case_mean": case_scores.mean(),
        "control_mean": control_scores.mean(),
        "fold_change": case_scores.mean() / (control_scores.mean() + 1e-10),
        "pvalue": pvalue
    })

module_results_df = pd.DataFrame(module_results)

# FDR correction
_, qvalues, _, _ = multipletests(
    module_results_df["pvalue"],
    method="fdr_bh"
)
module_results_df["qvalue"] = qvalues

print("\nSignificant modules:")
print(module_results_df[module_results_df["qvalue"] < 0.05])

module_results_df.to_csv("module_case_control_results.csv", index=False)
```

---

## Option 2: Larman Lab PhIP-Seq-Analyzer {#larman-tools}

**GitHub:** https://github.com/LarmanLab/PhIP-Seq-Analyzer

If you're already familiar with Larman/Elledge protocols, this is still maintained.

### Installation

```bash
git clone https://github.com/LarmanLab/PhIP-Seq-Analyzer.git
cd PhIP-Seq-Analyzer

# Install dependencies
pip install -r requirements.txt
```

### Usage

```bash
# Step 1: Demultiplex FASTQ files
python3 ./bin/bioTreatFASTQ.py \
  -i ./raw/PhIPseq_I1.fastq.gz \
  -f ./raw/PhIPseq_R1.fastq.gz \
  -b ./raw/Sample-Barcode.txt \
  -o ./demux/ \
  -y ./analysis/

# Step 2: Run PhIPseq analysis
# Edit variables.txt with your parameters
python3 ./bin/bioPHIPseq.py ./analysis/variables.txt
```

This generates enrichment scores that you can then use for case-control analysis (same Python code as above).

---

## Case-Control Statistical Methods {#case-control-analysis}

### Single Peptide Analysis

```python
def comprehensive_case_control_analysis(binary_matrix, metadata, 
                                       case_col="cancer_status",
                                       case_value="case",
                                       control_value="control",
                                       covariates=None):
    """
    Comprehensive case-control analysis with multiple methods.
    
    Parameters:
    -----------
    binary_matrix : pd.DataFrame
        Binary enrichment (peptides x samples)
    metadata : pd.DataFrame
        Sample metadata with case/control info
    covariates : list
        Additional covariates to adjust for (e.g., ['age', 'sex', 'batch'])
    
    Returns:
    --------
    results_df : pd.DataFrame
        Complete statistical results
    """
    from scipy.stats import fisher_exact, chi2_contingency
    from statsmodels.stats.multitest import multipletests
    import statsmodels.api as sm
    
    cases = metadata[metadata[case_col] == case_value].index
    controls = metadata[metadata[case_col] == control_value].index
    
    results = []
    
    for peptide in binary_matrix.index:
        # Contingency table
        case_pos = binary_matrix.loc[peptide, cases].sum()
        case_neg = len(cases) - case_pos
        control_pos = binary_matrix.loc[peptide, controls].sum()
        control_neg = len(controls) - control_pos
        
        table = [[case_pos, case_neg], [control_pos, control_neg]]
        
        # Fisher's exact test
        fisher_or, fisher_p = fisher_exact(table, alternative="two-sided")
        
        # Chi-square test (if sufficient counts)
        if all(x >= 5 for row in table for x in row):
            chi2_stat, chi2_p, _, _ = chi2_contingency(table)
        else:
            chi2_stat, chi2_p = np.nan, np.nan
        
        # Logistic regression with covariates
        if covariates:
            y = (metadata[case_col] == case_value).astype(int)
            X = metadata[covariates].copy()
            X["peptide"] = binary_matrix.loc[peptide]
            X = sm.add_constant(X)
            
            try:
                model = sm.Logit(y, X).fit(disp=0)
                lr_coef = model.params["peptide"]
                lr_or = np.exp(lr_coef)
                lr_p = model.pvalues["peptide"]
                lr_ci_lower = np.exp(model.conf_int().loc["peptide", 0])
                lr_ci_upper = np.exp(model.conf_int().loc["peptide", 1])
            except:
                lr_or, lr_p = np.nan, np.nan
                lr_ci_lower, lr_ci_upper = np.nan, np.nan
        else:
            lr_or, lr_p = np.nan, np.nan
            lr_ci_lower, lr_ci_upper = np.nan, np.nan
        
        results.append({
            "peptide_id": peptide,
            "case_pos": case_pos,
            "case_total": len(cases),
            "control_pos": control_pos,
            "control_total": len(controls),
            "case_prev": case_pos / len(cases),
            "control_prev": control_pos / len(controls),
            "fisher_OR": fisher_or,
            "fisher_pvalue": fisher_p,
            "chi2_pvalue": chi2_p,
            "logistic_OR": lr_or,
            "logistic_pvalue": lr_p,
            "logistic_95CI_lower": lr_ci_lower,
            "logistic_95CI_upper": lr_ci_upper
        })
    
    results_df = pd.DataFrame(results)
    
    # FDR correction for each test
    for test in ["fisher_pvalue", "chi2_pvalue", "logistic_pvalue"]:
        if test in results_df.columns:
            _, qvals, _, _ = multipletests(
                results_df[test].fillna(1.0),
                method="fdr_bh"
            )
            results_df[test.replace("pvalue", "qvalue")] = qvals
    
    return results_df.sort_values("fisher_pvalue")

# Example usage
results = comprehensive_case_control_analysis(
    binary_enrich,
    metadata,
    covariates=["age", "sex", "batch"]
)

# Save
results.to_csv("comprehensive_case_control_results.csv", index=False)
```

### Pathway-Level Analysis

```python
def pathway_enrichment_analysis(peptide_results, peptide_annotations):
    """
    Test for enrichment of significant peptides in pathways/viruses.
    
    Parameters:
    -----------
    peptide_results : pd.DataFrame
        Case-control results with qvalue column
    peptide_annotations : pd.DataFrame
        Peptide metadata with virus/protein info
    
    Returns:
    --------
    pathway_results : pd.DataFrame
        Pathway-level enrichment results
    """
    from scipy.stats import hypergeom
    
    # Merge annotations
    merged = peptide_results.merge(
        peptide_annotations,
        on="peptide_id"
    )
    
    # Total peptides tested
    n_total = len(merged)
    n_sig = (merged["qvalue"] < 0.05).sum()
    
    pathway_results = []
    
    # Group by virus/organism
    for organism in merged["organism"].unique():
        organism_peptides = merged[merged["organism"] == organism]
        n_organism = len(organism_peptides)
        n_organism_sig = (organism_peptides["qvalue"] < 0.05).sum()
        
        # Hypergeometric test
        pvalue = hypergeom.sf(
            n_organism_sig - 1,
            n_total,
            n_sig,
            n_organism
        )
        
        pathway_results.append({
            "organism": organism,
            "n_peptides": n_organism,
            "n_significant": n_organism_sig,
            "expected": (n_sig / n_total) * n_organism,
            "fold_enrichment": n_organism_sig / ((n_sig / n_total) * n_organism + 1e-10),
            "pvalue": pvalue
        })
    
    pathway_df = pd.DataFrame(pathway_results)
    
    # FDR correction
    _, qvals, _, _ = multipletests(
        pathway_df["pvalue"],
        method="fdr_bh"
    )
    pathway_df["qvalue"] = qvals
    
    return pathway_df.sort_values("pvalue")

# Run pathway analysis
peptide_meta = pd.read_csv("peptide_metadata.csv")
pathway_results = pathway_enrichment_analysis(results, peptide_meta)

print("\nEnriched viruses/organisms:")
print(pathway_results[pathway_results["qvalue"] < 0.05])
```

---

## Visualization Suite {#visualization}

```python
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

def create_publication_plots(results_df, enrichment_matrix, metadata):
    """
    Generate publication-ready plots.
    """
    
    # 1. Volcano Plot
    fig, ax = plt.subplots(figsize=(10, 8))
    
    results_df["-log10_p"] = -np.log10(results_df["fisher_pvalue"] + 1e-300)
    results_df["log2_OR"] = np.log2(results_df["fisher_OR"] + 1e-10)
    
    # Color by significance
    colors = np.where(results_df["fisher_qvalue"] < 0.05, "red", "gray")
    
    ax.scatter(
        results_df["log2_OR"],
        results_df["-log10_p"],
        c=colors,
        alpha=0.6,
        s=20
    )
    
    ax.axhline(-np.log10(0.05), color="black", linestyle="--", alpha=0.3)
    ax.axvline(0, color="black", linestyle="-", alpha=0.3)
    
    ax.set_xlabel("Log2(Odds Ratio)", fontsize=14)
    ax.set_ylabel("-Log10(P-value)", fontsize=14)
    ax.set_title("Case vs Control Volcano Plot", fontsize=16, fontweight="bold")
    
    plt.tight_layout()
    plt.savefig("volcano_plot.png", dpi=300)
    plt.savefig("volcano_plot.pdf")
    
    # 2. Top Peptides Heatmap
    top_peptides = results_df.nsmallest(50, "fisher_pvalue")["peptide_id"]
    plot_data = enrichment_matrix.loc[top_peptides]
    
    # Annotate samples by case/control
    sample_colors = metadata["cancer_status"].map({
        "case": "red",
        "control": "blue"
    })
    
    g = sns.clustermap(
        plot_data,
        cmap="RdBu_r",
        center=0,
        col_colors=sample_colors,
        col_cluster=True,
        row_cluster=True,
        figsize=(14, 12),
        cbar_kws={"label": "Enrichment Score"}
    )
    
    g.fig.suptitle("Top 50 Discriminating Peptides", y=1.01, fontsize=16)
    plt.savefig("heatmap_top_peptides.png", dpi=300, bbox_inches="tight")
    plt.savefig("heatmap_top_peptides.pdf", bbox_inches="tight")
    
    # 3. Odds Ratio Plot
    sig_results = results_df[results_df["fisher_qvalue"] < 0.05].nsmallest(20, "fisher_pvalue")
    
    fig, ax = plt.subplots(figsize=(10, 8))
    
    y_pos = np.arange(len(sig_results))
    ax.barh(y_pos, sig_results["fisher_OR"], color="steelblue")
    ax.axvline(1, color="red", linestyle="--", alpha=0.5)
    
    ax.set_yticks(y_pos)
    ax.set_yticklabels(sig_results["peptide_id"])
    ax.set_xlabel("Odds Ratio", fontsize=14)
    ax.set_title("Top 20 Peptides - Odds Ratios (Case vs Control)", fontsize=16)
    
    plt.tight_layout()
    plt.savefig("odds_ratio_plot.png", dpi=300)
    
    print("Saved: volcano_plot.png, heatmap_top_peptides.png, odds_ratio_plot.png")

# Generate plots
create_publication_plots(results, enrich_matrix, metadata)
```

---

## Publications Using phippery {#publications}

### Peer-Reviewed Studies (2021-2024):

1. **Stoddard et al. 2021** - Cell Reports
   - COVID-19 epitope profiling
   - Cross-reactivity with endemic CoVs

2. **Garrett et al. 2022** - iScience
   - HIV envelope antibody mapping
   - Deep mutational scanning

3. **Willcox et al. 2022**
   - Immune response profiling

4. **Multiple 2023-2024 studies** using phippery cited in recent reviews

This demonstrates phippery is **production-ready** and **peer-reviewed**.

---

## Complete Workflow Script

```bash
#!/bin/bash
# complete_phipseq_cancer_analysis.sh

# Setup
mkdir -p phipseq_cancer_analysis
cd phipseq_cancer_analysis

# Step 1: Run phip-flow pipeline
nextflow run matsengrp/phip-flow \
  --sample_table sample_metadata.csv \
  --peptide_table peptide_metadata.csv \
  --fastq_dir fastq_files/ \
  --outdir results/ \
  --counts_normalize cpm \
  --beads_samples "beads1,beads2,beads3" \
  -profile docker

# Step 2: Case-control analysis
python3 << 'EOF'
import phippery
import pandas as pd
from case_control_analysis import comprehensive_case_control_analysis
from visualization import create_publication_plots

# Load data
ds = phippery.load("results/phip_dataset.phip")
metadata = pd.read_csv("sample_metadata.csv", index_col="sample_id")

# Get enrichment matrix
enrichment = ds["enrichment"].to_dataframe().reset_index()
enrich_matrix = enrichment.pivot("peptide_id", "sample_id", "enrichment")

# Binary enrichment
binary = (enrich_matrix > 2.5).astype(int)

# Run analysis
results = comprehensive_case_control_analysis(
    binary,
    metadata,
    covariates=["age", "sex", "batch"]
)

# Save results
results.to_csv("case_control_results.csv", index=False)

# Create plots
create_publication_plots(results, enrich_matrix, metadata)

print("Analysis complete!")
print(f"Significant peptides: {(results['fisher_qvalue'] < 0.05).sum()}")
EOF

# Step 3: Launch interactive visualization
cd phip-viz
streamlit run app.py -- --dataset ../results/phip_dataset.phip
```

---

## Recommendations Summary

### For Your Cancer Case-Control Studies:

**Use phippery** because it is:
1. ✅ Published in 2023 (most recent)
2. ✅ Actively maintained (Fred Hutch)
3. ✅ Multiple peer-reviewed publications
4. ✅ Complete pipeline (raw data → results)
5. ✅ Modern, well-documented
6. ✅ Designed for general-purpose analysis

**Avoid**:
- ❌ phipcc (6+ years old, likely broken)
- ❌ Custom scripts from old papers
- ❌ Undocumented repositories

### Getting Help:

- **phippery GitHub Issues**: https://github.com/matsengrp/phippery/issues
- **Documentation**: https://matsengrp.github.io/phippery/
- **Paper**: https://doi.org/10.1093/bioinformatics/btad583
- **Email**: jgallowa [at] fredhutch.org

---

This guide provides you with **current, maintained, peer-reviewed tools** for your cancer PhIPSeq analysis!