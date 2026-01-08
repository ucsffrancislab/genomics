
#	20250925-Illumina-PhIP/20260108-CellImmunityPaper

Phage display sequencing reveals that genetic, environmental, and intrinsic factors influence variation of human antibody epitope repertoire

https://www.cell.com/immunity/fulltext/S1074-7613(23)00171-1



We interrogated a total of 344,000 peptides in 1,778 samples from 1,437 individuals (for 341 of whom we had data at two time points 4 years apart) from a northern Dutch population cohort (LLD) (Figure 1A).

Based on peptide sequence identity and prevalence we chose 2,815 peptides for further analyses


https://zenodo.org/records/7307894

https://github.com/erans99/PhIPSeq_external/tree/immunity


https://zenodo.org/records/7773433

https://github.com/abourgonje/Phip-Seq_LLD-IBD/tree/PhIPSeq_LLD_IBD


I asked Claude to access the paper and software and create a guide and code to implement the pipeline.
It appears to have written its own code and doesn't use theirs.


https://claude.ai/chat/3c8691f2-1f4a-4ac8-ab88-c7b68b73d1dd

```bash
# Python packages

python3 -m pip install --user --upgrade numpy pandas scipy matplotlib seaborn scikit-learn statsmodels biopython pysam
```

```R
install.packages(c("tidyverse", "vegan", "corrplot", "igraph", 
                   "pheatmap", "patchwork"))
if (!require("BiocManager")) install.packages("BiocManager")
BiocManager::install("WGCNA")
```





PREP phipseq_counts.csv to match the following expectations






```python

# Example data structure
import pandas as pd
import numpy as np

# Load your alignment counts
counts = pd.read_csv("phipseq_counts.csv", index_col=0)
# Shape: (n_peptides, n_samples)

print(f"Data dimensions: {counts.shape}")
print(f"Total reads per sample:\n{counts.sum(axis=0).describe()}")

```
