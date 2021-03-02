
#	TopMed Imputation

https://imputation.biodatacatalyst.nhlbi.nih.gov/

https://topmedimpute.readthedocs.io/en/latest/


##	Data preparation

The main steps for HRC are:

https://topmedimpute.readthedocs.io/en/latest/prepare-your-data/



```BASH
ln -s /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20210223-prep_for_imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab 

ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bed
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bim
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.fam
```


###	Download tool and sites

```BASH
wget https://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip
unzip HRC-1000G-check-bim-v4.3.0.zip
wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz 
```

Actually, link already downloaded versions


###	Create a frequency file

```BASH
module load plink/1.90b6.21

plink --freq --bfile AGS_illumina_for_QC --out AGS_illumina_for_QC



PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to AGS_illumina_for_QC.log.
Options in effect:
  --bfile AGS_illumina_for_QC
  --freq
  --out AGS_illumina_for_QC

62942 MB RAM detected; reserving 31471 MB for main workspace.
293698 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996943.
--freq: Allele frequencies (founders only) written to AGS_illumina_for_QC.frq .
```

###	Execute script

```BASH
perl HRC-1000G-check-bim.pl -b AGS_illumina_for_QC.bim -f AGS_illumina_for_QC.frq -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h



         Script to check plink .bim files against HRC/1000G for
        strand, id names, positions, alleles, ref/alt assignment
                    William Rayner 2015-2020
                        wrayner@well.ox.ac.uk

                               Version 4.3


Options Set:
Reference Panel:             HRC
Bim filename:                AGS_illumina_for_QC.bim
Reference filename:          HRC.r1-1.GRCh37.wgs.mac5.sites.tab
Allele frequencies filename: AGS_illumina_for_QC.frq
Plink executable to use:     plink

Chromosome flag set:         No
Allele frequency threshold:  0.2

Path to plink bim file: /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation

Reading HRC.r1-1.GRCh37.wgs.mac5.sites.tab
2000000
4000000
6000000
8000000
10000000
12000000
14000000
16000000
18000000
20000000
22000000
24000000
26000000
28000000
30000000
32000000
34000000
36000000
38000000
40000000
40405506
 ...Done


Details written to log file: /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/LOG-AGS_illumina_for_QC-HRC.txt

Creating variant lists
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Force-Allele1-AGS_illumina_for_QC-HRC.txt
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Strand-Flip-AGS_illumina_for_QC-HRC.txt
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/ID-AGS_illumina_for_QC-HRC.txt
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Position-AGS_illumina_for_QC-HRC.txt
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Chromosome-AGS_illumina_for_QC-HRC.txt
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Exclude-AGS_illumina_for_QC-HRC.txt
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/FreqPlot-AGS_illumina_for_QC-HRC.txt


Matching to HRC

Position Matches
 ID matches HRC 0
 ID Doesn't match HRC 1246
 Total Position Matches 1246
ID Match
 Position different from HRC 292401
No Match to HRC 50
Skipped (MT) 0
Total in bim file 293698
Total processed 293697

Indels 0

SNPs not changed 71633
SNPs to change ref alt 195080
Strand ok 224469
Total Strand ok 266713

Strand to change 68528
Total checked 293647
Total checked Strand 292997
Total removed for allele Frequency diff > 0.2 707
Palindromic SNPs with Freq > 0.4 2


Non Matching alleles 648
ID and allele mismatching 351; where HRC is . 351
Duplicates removed 1


Writing plink commands to: Run-plink.sh
```





```BASH
module load plink/1.90b6.21

sh Run-plink.sh


PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP1.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC
  --exclude /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Exclude-AGS_illumina_for_QC-HRC.txt
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP1

62942 MB RAM detected; reserving 31471 MB for main workspace.
293698 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
--exclude: 292290 variants remaining.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996951.
292290 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP1.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP1.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP1.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP2.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP1
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP2
  --update-chr
  --update-map /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Chromosome-AGS_illumina_for_QC-HRC.txt

Note: --update-map <filename> + parameter-free --update-chr deprecated.  Use
--update-chr <filename> instead.
62942 MB RAM detected; reserving 31471 MB for main workspace.
292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996951.
292290 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--update-chr: 292034 values updated, 367 variant IDs not present.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP2.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP2.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP2.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP3.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP2
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP3
  --update-map /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Position-AGS_illumina_for_QC-HRC.txt

62942 MB RAM detected; reserving 31471 MB for main workspace.
292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
--update-map: 292034 values updated, 367 variant IDs not present.
Warning: Base-pair positions are now unsorted!
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996951.
292290 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP3.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP3.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP3.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP4.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP3
  --flip /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Strand-Flip-AGS_illumina_for_QC-HRC.txt
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP4

62942 MB RAM detected; reserving 31471 MB for main workspace.
292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
--flip: 68096 SNPs flipped, 432 SNP IDs not present.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996951.
292290 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP4.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP4.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP4.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated.log.
Options in effect:
  --a2-allele /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/Force-Allele1-AGS_illumina_for_QC-HRC.txt
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/TEMP4
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated

62942 MB RAM detected; reserving 31471 MB for main workspace.
292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996951.
--a2-allele: 292290 assignments made.
292290 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr1.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 1
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr1
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
22170 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997239.
22170 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr1.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr1.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr1.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr1.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 1
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr1
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
22170 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997239.
22170 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr1.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr2.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 2
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr2
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
24042 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997291.
24042 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr2.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr2.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr2.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr2.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 2
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr2
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
24042 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997291.
24042 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr2.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr3.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 3
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr3
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
20479 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997216.
20479 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr3.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr3.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr3.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr3.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 3
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr3
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
20479 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997216.
20479 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr3.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr4.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 4
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr4
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
18041 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996779.
18041 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr4.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr4.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr4.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr4.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 4
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr4
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
18041 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996779.
18041 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr4.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr5.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 5
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr5
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
18309 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996292.
18309 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr5.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr5.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr5.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr5.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 5
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr5
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
18309 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996292.
18309 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr5.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr6.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 6
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr6
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
19599 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.99709.
19599 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr6.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr6.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr6.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr6.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 6
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr6
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
19599 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.99709.
19599 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr6.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr7.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 7
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr7
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
15811 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996856.
15811 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr7.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr7.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr7.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr7.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 7
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr7
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
15811 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996856.
15811 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr7.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr8.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 8
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr8
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
17295 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.99711.
17295 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr8.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr8.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr8.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr8.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 8
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr8
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
17295 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.99711.
17295 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr8.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr9.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 9
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr9
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
15088 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997027.
15088 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr9.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr9.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr9.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr9.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 9
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr9
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
15088 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997027.
15088 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr9.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr10.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 10
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr10
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
14770 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.99703.
14770 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr10.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr10.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr10.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr10.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 10
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr10
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
14770 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.99703.
14770 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr10.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr11.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 11
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr11
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
13900 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996923.
13900 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr11.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr11.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr11.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr11.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 11
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr11
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
13900 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996923.
13900 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr11.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr12.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 12
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr12
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
14240 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996813.
14240 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr12.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr12.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr12.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr12.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 12
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr12
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
14240 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996813.
14240 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr12.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr13.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 13
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr13
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
10880 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997021.
10880 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr13.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr13.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr13.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr13.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 13
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr13
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
10880 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997021.
10880 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr13.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr14.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 14
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr14
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
9430 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997295.
9430 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr14.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr14.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr14.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr14.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 14
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr14
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
9430 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997295.
9430 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr14.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr15.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 15
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr15
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
8506 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.995711.
8506 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr15.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr15.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr15.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr15.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 15
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr15
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
8506 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.995711.
8506 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr15.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr16.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 16
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr16
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
8551 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997173.
8551 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr16.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr16.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr16.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr16.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 16
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr16
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
8551 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997173.
8551 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr16.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr17.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 17
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr17
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
7923 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996912.
7923 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr17.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr17.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr17.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr17.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 17
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr17
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
7923 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996912.
7923 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr17.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr18.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 18
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr18
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
9969 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996913.
9969 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr18.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr18.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr18.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr18.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 18
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr18
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
9969 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996913.
9969 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr18.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr19.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 19
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr19
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
5543 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996303.
5543 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr19.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr19.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr19.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr19.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 19
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr19
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
5543 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996303.
5543 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr19.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr20.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 20
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr20
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
7413 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997393.
7413 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr20.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr20.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr20.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr20.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 20
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr20
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
7413 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997393.
7413 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr20.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr21.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 21
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr21
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
5226 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996235.
5226 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr21.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr21.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr21.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr21.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 21
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr21
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
5226 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.996235.
5226 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr21.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr22.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 22
  --make-bed
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr22
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
5105 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997071.
5105 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
--make-bed to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr22.bed
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr22.bim
+
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr22.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr22.log.
Options in effect:
  --bfile /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated
  --chr 22
  --out /francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr22
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
5105 out of 292290 variants loaded from .bim file.
4619 people (2005 males, 2614 females) loaded from .fam.
4619 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4619 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.997071.
5105 variants and 4619 people pass filters and QC.
Among remaining phenotypes, 669 are cases and 3950 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/AGS_illumina_for_QC-updated-chr22.vcf
... done.
```


The latest version of the above scripts automatically creates vcf files.
The do still need compressed though.


```BASH
module load htslib/1.10.2

for vcf in *vcf; do
echo $vcf
bgzip $vcf
done

chmod a-w *
chmod +w README.md
```

That should be good.




##	Upload

Copy the files locally.
```
scp c4:/francislab/data1/working/20210302-AGS-illumina/20210302-prep_for_imputation/*vcf.gz ./
```

Then upload to the web app.




https://imputation.biodatacatalyst.nhlbi.nih.gov/

Login

Run > Genotype Imputation (Minimac4) 1.5.7


Name : 20210302

Reference Panel : 
* **TOPMed r2** (only option)

Input Files : File Upload (selected my local copies for upload)

Array build : 
* **GRCh37/hg19**
* GRCh38/hg38

rsq Filter : 
* off
* 0.001
* **0.1**
* 0.2
* 0.3

Phasing : 
* **Eagle v2.4 (unphased input)**
* No phasing (phased input)

QC Frequency Check : 
* **vs TOPMed Panel**
* Skip

Mode : 
* **Quality Control and Imputation**
* Quality Control and Phasing Only
* Quality Control Only


**Submit Job**


Wait for files to upload.  This took me about 15 minutes.


```
Input Validation

22 valid VCF file(s) found.

Samples: 4619
Chromosomes: 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9
SNPs: 292290
Chunks: 291
Datatype: unphased
Build: hg19
Reference Panel: apps@topmed-r2@1.0.0 (hg38)
Population: all
Phasing: eagle
Mode: imputation
Rsq filter: 0.1
```

```
Quality Control

Uploaded data is hg19 and reference is hg38.

Lift Over

Calculating QC Statistics

Statistics:
Alternative allele frequency > 0.5 sites: 97,485
Reference Overlap: 99.68 %
Match: 290,463
Allele switch: 699
Strand flip: 0
Strand flip and allele switch: 0
A/T, C/G genotypes: 0
Filtered sites:
Filter flag set: 0
Invalid alleles: 0
Multiallelic sites: 0
Duplicated sites: 0
NonSNP sites: 0
Monomorphic sites: 0
Allele mismatch: 80
SNPs call rate < 90%: 98

Excluded sites in total: 178
Remaining sites in total: 291,064
See snps-excluded.txt for details
Typed only sites: 923
See typed-only.txt for details

Warning: 3 Chunk(s) excluded: < 3 SNPs (see chunks-excluded.txt for details).
Warning: 1 Chunk(s) excluded: at least one sample has a call rate < 50.0% (see chunks-excluded.txt for details).
Remaining chunk(s): 288
```

```
Quality Control (Report)

Execution successful.
```

Then wait for the process. Started ...
...


I was emailed a password which I put in a file called `password`

```BASH
mkdir imputation
cd imputation







chmod a-w *

for zip in chr*zip ; do
echo $zip
unzip -P $( cat password ) $zip
done
```







