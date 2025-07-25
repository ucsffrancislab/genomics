
#	20210223-TCGA-GBMLGG-WTCCC-Affy6

https://pmc.ncbi.nlm.nih.gov/articles/PMC9247888/


The third dataset included 786 glioma cases from The Cancer Genome Atlas (TCGA) with available molecular data genotyped on the Affymetrix 6.0 array. Cancer-free controls were assembled from two Wellcome Trust Case Control Consortium (WTCCC) studies genotyped using the Affymetrix 6.0 array: 2,917 controls from the 1958 British Birth cohort and 2,794 controls from the UK Blood Service control group.




# Geno Guerra
# 20210223

This is a merged dataset which contains 
TCGA_LGG_GBM Affy 6 samples
WTCCC National Blood Donor Affy 6 samples
WTCCC British Birth Cohort Affy 6 samples

These "for_QC" binary files have undergone necessary pre-imputation QC steps, as documented in QC_steps.txt (to be added) 

Coordinates are GrCh37/hg19

Pre-imputation there are 733799 SNPs, some ancestry specific
6716 samples (~850 TCGA, rest WTCCC)

Ancestries included are EUR, AFR (TCGA only), and ADMX (= no single european,african,asian,american component >0.7)
 

FAM file format
1 Family ID ('FID')
2 Within-family ID ('IID'; cannot be '0')
3 Within-family ID of father ('0' if father isn't in dataset)
4 Within-family ID of mother ('0' if mother isn't in dataset)
5 Sex code ('1' = male, '2' = female, '0' = unknown)
6 Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)


```

cut -d' ' -f2,5,6 TCGA_WTCCC_for_QC.fam | awk '(/WTCC/){print "WTCCC",$2,$3}(/TCGA/){print substr($1,14,2),$2,$3}' | sort | uniq -c
     74 01 1 1
    798 10 1 1
      1 11 1 1
   2169 WTCCC 1 1
   2130 WTCCC 2 1

```


