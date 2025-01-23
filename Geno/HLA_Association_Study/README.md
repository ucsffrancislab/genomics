
#  Notes on running an association analysis on HLA alleles.

This analysis, like all of our genetic analysis, is conducted separately on each of the three array datasets:

```
20210226-AGS-Mayo-Oncoarray
20210223-TCGA-GBMLGG-WTCCC-Affy6
20210302-AGS-illumina
```

The data we are currently using for HLA-based analysis is based on the SNP2HLA imputed results from our imputed genome arrays. The analysis is very similar to the GWAS scripts, the only difference is it computes associations with HLA alleles instead of SNPs.

Locally, on Box, the scripts to prep the SNP data for SNP2HLA are in `/Box-Box/20241126-Geno-Scripts-Data-Notes/Script_Repository/snp2hla`.

`cp /francislab/data1/users/gguerra/20241126-Geno-Scripts-Data-Notes/Script_Repository/snp2hla/* ./`


The scripts to run risk association anlayses are located on C4 in `/francislab/data1/working/[ARRAY]/*scripts/snp2HLA`. Use the most recently dated version.

The file `/francislab/data1/working/[ARRAY]/20210305-snp2hla/matchedimputed/keepers.txt` tells the script which alleles to analyze. It doesn't hurt to analyze all, but this was just a QC step to remove anything too rare or imputed too poorly.

Results from existing runs are in `/francislab/data1/working/[ARRAY]/20210305-snp2hla/results`

Similar to other analyses, these can be meta analyzed across the three arrays to produce a single meta-association with various glioma risks.



