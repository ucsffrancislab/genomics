
# Notes for running GWAS using our three available datasets:

20210226-AGS-Mayo-Oncoarray

20210223-TCGA-GBMLGG-WTCCC-Affy6

20210302-AGS-illumina

The data we have been using to run our GWAS is in the `*for_analysis` subfolders. For both of the AGS sets, it is `20210303-for_analysis`, for the TCGA set, we have re processed the data, so use `20230223-for_analysis`. 

These files are generally just reformatted versions (with basic QC) of the `*prep_for_imputation/imputation` vcf files, since the GWAS script takes plink2 pgen files. 

The scripts you would need are in (for example) `/francislab/data1/working/20210302-AGS-illumina/20210310-scripts/GWAS` , there exists identical repositiories for each of the 3 datasets. They have their slight nuances (primarily different covariates available) and so I have maintained different, but nearly identical scripts. Locally they are in the Script_Repository folder on Box. 




/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20210315-scripts/GWAS/
20210315-GWAS-glioma-script.sh
20210316-subtype-GWAS-glioma-script.sh
20210318-subtype-GWAS_glioma_script.sh

/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210310-scripts/GWAS/
20210312-GWAS-glioma-script.sh
20210316-GWAS-glioma-script.sh
20210318-GWAS-glioma-script.sh

/francislab/data1/working/20210302-AGS-illumina/20210310-scripts/GWAS
20210310-GWAS-glioma-script.sh
20210316-GWAS-glioma-script.sh
20210318-GWAS-glioma-script.sh




The GWAS scripts take in a few files:
1. a pointer to the plink files (`--pfile $FILEPREFIX`)

2. A file of the IDs of people you want to include (`--keep $FILE`)

3. A covariate file indicating binary 1/0 inclusion as case or control (`--pheno`). This can have multiple columns indicating different groupings (e.g. and idh mut vs control, or all case vs control). The script will run a GWAS on all of these columns in one command, just provide the column names with (`--pheno-name`). I generally have created these in R and added them as additional columns to the covariate file. 

4. A covariate file, with all of the adjustment covariates, like sex, age, PCs etc. (`--covar`), specify the covariates you want to include with (`--covar-name`)

This will produce a GWAS file of SNPs and each of their effects. 


Generally, I run this for all three of our datasets, and then use a meta-analysis software to combine the results into a single estimated effect (using the software "metal", see meta-analysis folder for more details.)


EXISTING RESULTS:
The existing GWAS results for each of the three arrays are in `/francislab/data1/working/[ARRAY]/20210310-GWAS/results/chr*/*.hybrid`
These include all various subtype specific analyses. 

