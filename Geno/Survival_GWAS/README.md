
# Guide to running a survival analysis GWAS on the cluster. 

Similar to the GWAS, these are run separately on:

20210226-AGS-Mayo-Oncoarray

20210223-TCGA-GBMLGG-WTCCC-Affy6

20210302-AGS-illumina

These scripts run a Cox Proportional Hazards regression on each SNP dosage level. 

The scripts of interest are located in `/francislab/data1/working/[ARRAY]/*scripts/Pharma/Survival_GWAS` for each of the three datasets. 

There are two methods to use, one is gwasurvivr, which is the most standard analysis, it does exactly like a GWAS and fit a model to each SNP. The second is SPAcox, which uses a saddle-point approximation method to better estimate p-values of rare-variants. MOST of the time, gwasurvivr is appropriate. What I do is run both, concat the results, so I can compare the p-values of the two models. The important thing to note is that gwasurvivr will provide estimates of the effect size (e.g. the hazard ratio), but SPAcox will ONLY report the p-value. So if you want effect sizes, you must run gwasurvivr. 


These scripts rely on a vcf file of SNP data, with an accompanying `.tbi` index file. The script `CollapseVCFs.sh` will take in a list of SNPs, create a big VCF file from the `*prep_for_imputation/imputation` folder, and generate the accompanying index file. 

Unlike the GWAS file, I designed this one to take in a list of SNPs (via the `CollapseVCFs.sh` file), since the projects I was interested in were more targeted. You can easily modify this by passing a much larger list of SNPs, or just skipping that step completely. 

Both `GWASurvivr_shell.sh` and `spaCox_shell.sh` loop over subsets files (e.g. all glioma, just IDH mut etc.) to run all possible subsets of interest. These files are lists of sample IDs. 

They respectively call `gwasurvivr.R` and `SPACox.R` . For these files, I have a hard-coded set of adjustment variables. What would be most appropriate would be to have this hard coded list set, and remove any which don't have much variance in the samples of interest (e.g. don't adjust for the idhmut variable if you are running and IDH-mutant specific analysis). 

I also have a merger script which will, as I mentioned above, merge the SPAcox result with the more detailed gwasurvivr results. This is `merger_spaCox_GWASurvivr_shell.sh` which calls `SPACox_GWASurvivr_merger.R`. 

Ultimately, the output of this merger file (one for each of the 3 arrays/datasets) can be meta-analyzed using metal. 


An advantage of these scripts is that you can pretty easily run a targeted analysis on any subset of SNPs. 


