

... single-end on an Illumina NovaSeq 6000 to an average depth of 7.5 million reads per sample.

Bulk RNA-sequencing data processing
Adapter sequences and low-quality score bases were trimmed from reads using Trim Galore
(v0.6.2, Cutadapt v2.2) (49) in single-end mode (-q 20 --paired --phred33). Trimmed reads were
pseudoaligned to a custom transcriptome containing both the Homo sapiens reference
transcriptome (GRCh38) and the Cal/04/09 transcriptome (downloaded from Ensembl) using the
quant function in kallisto (v0.43) (50) (average depth of 4.3 million pseudoaligned reads per
sample for the true bulk RNA-seq samples). Gene-level expression estimates were calculated using
the R (v3.6.3) package tximport (v1.14.2) (51). Expression data was filtered for protein-coding
genes that were sufficiently expressed across all samples (median logCPM > 1). After removing
non-coding and lowly-expressed genes, normalization factors to scale the raw library sizes were
calculated using calcNormFactors in edgeR (v3.26.8) (52). The voom function in limma (v3.40.6)
(8) was used to apply these size factors, estimate the mean-variance relationship, and convert
counts to logCPM values. Technical effects (e.g., library preparation batch) were regressed using
the ComBat function in sva (v3.32.1) (https://bioconductor.org/packages/sva/). A model
evaluating the technical effect of experiment batch (~ 0 + batch, where batch corresponds to a
factor variable representing the 15 experimental batches) on gene expression was fit using the
lmFit and eBayes functions, and model residuals were obtained using the residuals.MArrayLM
function in limma (8). The average experiment batch effect was then computed by taking the mean
of the capture coefficients across all 15 batches per gene, and this average effect was added back
to the residuals.



Says both "single-end mode" and "--paired"?



