
#	20250700-AGS-CIDR-ONCO-Illumina

Expecting AGS SNP data from CIDR
447 dna glioma - gwas snp arrays - add to existing case set, rerun geno’s analyses, re impute everything, genotyping, PRS. about a month


Want to process with previous AGS SNP data sets Illumina (il370) and Mayo Onco (onco)

il370 and onco contain different AGS ids.
I expect CIDR to as well.

I think that all of the cases are GBMs.



The il370 also includes Non AGS control data.

There also exists "QC'd" dataset that I believe Geno provided but I don't know how this was done.
In addition, the QC'd Onco dataset includes about 3000 unknown case and control samples.

Both of the old datasets have been processed a number of times already, but I will begin again.

It appears to be recommended to impute separately first, and then combine after.






wc -l /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.fam /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/il370_4677.fam 
  4619 /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.fam
  4677 /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/il370_4677.fam
  9296 total

wc -l /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.fam /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/onco_1347.fam 
  4365 /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.fam
  1347 /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/onco_1347.fam
  5712 total


Not sure where the extra subjects in the ONCO set came from

Onco_1347 initially has 1347. All AGS (some case, some control)
QC’d Onco has over 3000 additional. Some case, some control)

Il370_4677 initially has 4677. 1287 AGS (some case, some control), 3390 something else ( all control 1 )

Different AGS ids

[gwendt@c4-log2 ~]$ grep AGS /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/il370_4677.fam | cut -d' ' -f6 | sort | uniq -c
    602 1
    685 2
[gwendt@c4-log2 ~]$ grep AGS /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/onco_1347.fam | cut -d' ' -f6 | sort | uniq -c
    333 1
   1014 2



Extract and rename AGS ids. 
Prep AGS data 
Investigate previous AGS and runs and the format







