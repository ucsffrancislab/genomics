# Glioma polygenic risk scores and linkage disequilibrium reference panel from: Genome-wide Polygenic Risk Scores Predict Risk of Glioma and Molecular Subtypes

This dataset includes single nucleotide polymorphisms (SNPs) and corresponding weights for polygenic risk scores (PRS) of adult diffuse glioma. In addition, we include the custom linkage disequilibrium (LD) reference panel used in PRS development, which is an expanded version of the LD reference panel for European individuals constructed using the 1000 Genomes Project phase 3 samples made available by [Ge et al.](https://github.com/getian107/PRScs). The data were used for risk prediction and the detection of glial tumor subtypes. 

## Description of the data and file structure

`X_scoring_system.txt.gz` is the scoring system of the PRS model for glioma overall (X=`allGlioma`), glioblastoma (X=`GBM`), non-glioblastoma (X=`nonGBM`), IDH wildtype (X=`IDHwt`), IDH mutant (X=`IDHmut`), IDH mutant 1p19q codeletion (X=`IDHmut_1p19qcodel`) and IDH mutant 1p19q non-codeletion (X=`IDHmut_1p19qnoncodel`). There are three columns: `ID` (1st column) is the SNP ID, `prs_allele` (2nd column) is the effect allele, and `prs_weight` (3rd column) is the corresponding PRS weight. 

`ldblk_1kg_eur.tar.gz` is the custom LD reference panel for European individuals constructed using the 1000 Genomes Project phase 3 samples. 
