
#	TopMed Imputation

https://imputation.biodatacatalyst.nhlbi.nih.gov/

https://topmedimpute.readthedocs.io/en/latest/


##	Data preparation

The main steps for HRC are:

https://topmedimpute.readthedocs.io/en/latest/prepare-your-data/



```BASH
ln -s /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20210223-prep_for_imputation/HRC-1000G-check-bim.plh
ln -s /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20210223-prep_for_imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab 

ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bed
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bim
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.fam
```


###	Download tool and sites

```BASH
#wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
#unzip HRC-1000G-check-bim-v4.2.7.zip
wget https://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip
unzip HRC-1000G-check-bim-v4.3.0.zip
wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz 
```


###	Create a frequency file

```BASH
module load plink/1.90b6.21

plink --freq --bfile AGS_Mayo_Oncoarray_for_QC --out AGS_Mayo_Oncoarray_for_QC


PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to AGS_Mayo_Oncoarray_for_QC.log.
Options in effect:
  --bfile AGS_Mayo_Oncoarray_for_QC
  --freq
  --out AGS_Mayo_Oncoarray_for_QC

62942 MB RAM detected; reserving 31471 MB for main workspace.
403388 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987959.
--freq: Allele frequencies (founders only) written to
AGS_Mayo_Oncoarray_for_QC.frq .
```

###	Execute script

```BASH
perl HRC-1000G-check-bim.pl -b AGS_Mayo_Oncoarray_for_QC.bim -f AGS_Mayo_Oncoarray_for_QC.frq -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h



                                      Script to check plink .bim files against HRC/1000G for
                                     strand, id names, positions, alleles, ref/alt assignment
                                                      William Rayner 2015
                                                     wrayner@well.ox.ac.uk

                                                          Version 4.2.7


Options Set:
Reference Panel:             HRC
Bim filename:                AGS_Mayo_Oncoarray_for_QC.bim
Reference filename:          HRC.r1-1.GRCh37.wgs.mac5.sites.tab
Allele frequencies filename: AGS_Mayo_Oncoarray_for_QC.frq
Allele frequency threshold:  0.2


Reading HRC.r1-1.GRCh37.wgs.mac5.sites.tab
 100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000 1500000 1600000 1700000 1800000 1900000 2000000 2100000 2200000 2300000 2400000 2500000 2600000 2700000 2800000 2900000 3000000 3100000 3200000 3300000 3400000 3500000 3600000 3700000 3800000 3900000 4000000 4100000 4200000 4300000 4400000 4500000 4600000 4700000 4800000 4900000 5000000 5100000 5200000 5300000 5400000 5500000 5600000 5700000 5800000 5900000 6000000 6100000 6200000 6300000 6400000 6500000 6600000 6700000 6800000 6900000 7000000 7100000 7200000 7300000 7400000 7500000 7600000 7700000 7800000 7900000 8000000 8100000 8200000 8300000 8400000 8500000 8600000 8700000 8800000 8900000 9000000 9100000 9200000 9300000 9400000 9500000 9600000 9700000 9800000 9900000 10000000 10100000 10200000 10300000 10400000 10500000 10600000 10700000 10800000 10900000 11000000 11100000 11200000 11300000 11400000 11500000 11600000 11700000 11800000 11900000 12000000 12100000 12200000 12300000 12400000 12500000 12600000 12700000 12800000 12900000 13000000 13100000 13200000 13300000 13400000 13500000 13600000 13700000 13800000 13900000 14000000 14100000 14200000 14300000 14400000 14500000 14600000 14700000 14800000 14900000 15000000 15100000 15200000 15300000 15400000 15500000 15600000 15700000 15800000 15900000 16000000 16100000 16200000 16300000 16400000 16500000 16600000 16700000 16800000 16900000 17000000 17100000 17200000 17300000 17400000 17500000 17600000 17700000 17800000 17900000 18000000 18100000 18200000 18300000 18400000 18500000 18600000 18700000 18800000 18900000 19000000 19100000 19200000 19300000 19400000 19500000 19600000 19700000 19800000 19900000 20000000 20100000 20200000 20300000 20400000 20500000 20600000 20700000 20800000 20900000 21000000 21100000 21200000 21300000 21400000 21500000 21600000 21700000 21800000 21900000 22000000 22100000 22200000 22300000 22400000 22500000 22600000 22700000 22800000 22900000 23000000 23100000 23200000 23300000 23400000 23500000 23600000 23700000 23800000 23900000 24000000 24100000 24200000 24300000 24400000 24500000 24600000 24700000 24800000 24900000 25000000 25100000 25200000 25300000 25400000 25500000 25600000 25700000 25800000 25900000 26000000 26100000 26200000 26300000 26400000 26500000 26600000 26700000 26800000 26900000 27000000 27100000 27200000 27300000 27400000 27500000 27600000 27700000 27800000 27900000 28000000 28100000 28200000 28300000 28400000 28500000 28600000 28700000 28800000 28900000 29000000 29100000 29200000 29300000 29400000 29500000 29600000 29700000 29800000 29900000 30000000 30100000 30200000 30300000 30400000 30500000 30600000 30700000 30800000 30900000 31000000 31100000 31200000 31300000 31400000 31500000 31600000 31700000 31800000 31900000 32000000 32100000 32200000 32300000 32400000 32500000 32600000 32700000 32800000 32900000 33000000 33100000 33200000 33300000 33400000 33500000 33600000 33700000 33800000 33900000 34000000 34100000 34200000 34300000 34400000 34500000 34600000 34700000 34800000 34900000 35000000 35100000 35200000 35300000 35400000 35500000 35600000 35700000 35800000 35900000 36000000 36100000 36200000 36300000 36400000 36500000 36600000 36700000 36800000 36900000 37000000 37100000 37200000 37300000 37400000 37500000 37600000 37700000 37800000 37900000 38000000 38100000 38200000 38300000 38400000 38500000 38600000 38700000 38800000 38900000 39000000 39100000 39200000 39300000 39400000 39500000 39600000 39700000 39800000 39900000 40000000 40100000 40200000 40300000 40400000 Done
Matching to HRC

Position Matches
 ID matches HRC 300766
 ID Doesn't match HRC 101614
 Total Position Matches 402380
ID Match
 Different position to HRC 1005
No Match to HRC 2
Skipped (X, XY, Y, MT) 0
Total in bim file 403388
Total processed 403387

Indels (ignored in r1) 0

SNPs not changed 103438
SNPs to change ref alt 299883
Strand ok 403153
Total Strand ok 403321

Strand to change 232
Total checked 403385
Total checked Strand 403385
Total removed for allele Frequency diff > 0.2 118
Use of uninitialized value $palin in concatenation (.) or string at HRC-1000G-check-bim.pl line 568, <IN> line 403388.
Palindromic SNPs with Freq > 0.4 


Non Matching alleles 0
ID and allele mismatching 0; where HRC is . 0
Duplicates removed 1
Use of uninitialized value $palin in concatenation (.) or string at HRC-1000G-check-bim.pl line 583, <IN> line 403388.
```

Downloaded to latest version of script.

```BASH
perl HRC-1000G-check-bim.pl -b AGS_Mayo_Oncoarray_for_QC.bim -f AGS_Mayo_Oncoarray_for_QC.frq -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

         Script to check plink .bim files against HRC/1000G for
        strand, id names, positions, alleles, ref/alt assignment
                    William Rayner 2015-2020
                        wrayner@well.ox.ac.uk

                               Version 4.3


Options Set:
Reference Panel:             HRC
Bim filename:                AGS_Mayo_Oncoarray_for_QC.bim
Reference filename:          HRC.r1-1.GRCh37.wgs.mac5.sites.tab
Allele frequencies filename: AGS_Mayo_Oncoarray_for_QC.frq
Plink executable to use:     plink

Chromosome flag set:         No
Allele frequency threshold:  0.2

Path to plink bim file: /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation

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


Details written to log file: /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/LOG-AGS_Mayo_Oncoarray_for_QC-HRC.txt

Creating variant lists
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Force-Allele1-AGS_Mayo_Oncoarray_for_QC-HRC.txt
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Strand-Flip-AGS_Mayo_Oncoarray_for_QC-HRC.txt
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/ID-AGS_Mayo_Oncoarray_for_QC-HRC.txt
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Position-AGS_Mayo_Oncoarray_for_QC-HRC.txt
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Chromosome-AGS_Mayo_Oncoarray_for_QC-HRC.txt
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Exclude-AGS_Mayo_Oncoarray_for_QC-HRC.txt
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/FreqPlot-AGS_Mayo_Oncoarray_for_QC-HRC.txt


Matching to HRC

Position Matches
 ID matches HRC 300766
 ID Doesn't match HRC 101614
 Total Position Matches 402380
ID Match
 Position different from HRC 1005
No Match to HRC 2
Skipped (MT) 0
Total in bim file 403388
Total processed 403387

Indels 0

SNPs not changed 103438
SNPs to change ref alt 299883
Strand ok 403153
Total Strand ok 403321

Strand to change 232
Total checked 403385
Total checked Strand 403385
Total removed for allele Frequency diff > 0.2 118
Palindromic SNPs with Freq > 0.4 0


Non Matching alleles 0
ID and allele mismatching 0; where HRC is . 0
Duplicates removed 1


Writing plink commands to: Run-plink.sh
```





```BASH
module load plink/1.90b6.21

sh Run-plink.sh



PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP1.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC
  --exclude /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Exclude-AGS_Mayo_Oncoarray_for_QC-HRC.txt
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP1

62942 MB RAM detected; reserving 31471 MB for main workspace.
403388 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
--exclude: 403267 variants remaining.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988227.
403267 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP1.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP1.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP1.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP2.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP1
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP2
  --update-chr
  --update-map /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Chromosome-AGS_Mayo_Oncoarray_for_QC-HRC.txt

Note: --update-map <filename> + parameter-free --update-chr deprecated.  Use
--update-chr <filename> instead.
62942 MB RAM detected; reserving 31471 MB for main workspace.
403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988227.
403267 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--update-chr: 926 values updated, 79 variant IDs not present.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP2.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP2.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP2.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP3.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP2
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP3
  --update-map /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Position-AGS_Mayo_Oncoarray_for_QC-HRC.txt

62942 MB RAM detected; reserving 31471 MB for main workspace.
403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
--update-map: 926 values updated, 79 variant IDs not present.
Warning: Base-pair positions are now unsorted!
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988227.
403267 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP3.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP3.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP3.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP4.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP3
  --flip /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Strand-Flip-AGS_Mayo_Oncoarray_for_QC-HRC.txt
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP4

62942 MB RAM detected; reserving 31471 MB for main workspace.
403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
--flip: 217 SNPs flipped, 15 SNP IDs not present.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988227.
403267 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP4.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP4.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP4.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated.log.
Options in effect:
  --a2-allele /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/Force-Allele1-AGS_Mayo_Oncoarray_for_QC-HRC.txt
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/TEMP4
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated

62942 MB RAM detected; reserving 31471 MB for main workspace.
403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988227.
--a2-allele: 403267 assignments made.
403267 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr1.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 1
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr1
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
28124 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988406.
28124 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr1.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr1.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr1.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr1.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 1
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr1
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
28124 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988406.
28124 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr1.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr2.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 2
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr2
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
33743 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988266.
33743 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr2.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr2.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr2.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr2.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 2
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr2
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
33743 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988266.
33743 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr2.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr3.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 3
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr3
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
26918 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988476.
26918 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr3.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr3.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr3.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr3.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 3
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr3
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
26918 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988476.
26918 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr3.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr4.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 4
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr4
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
21767 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988448.
21767 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr4.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr4.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr4.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr4.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 4
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr4
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
21767 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988448.
21767 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr4.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr5.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 5
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr5
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
26452 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.986795.
26452 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr5.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr5.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr5.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr5.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 5
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr5
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
26452 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.986795.
26452 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr5.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr6.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 6
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr6
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
32347 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987472.
32347 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr6.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr6.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr6.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr6.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 6
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr6
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
32347 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987472.
32347 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr6.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr7.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 7
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr7
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
21576 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987996.
21576 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr7.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr7.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr7.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr7.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 7
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr7
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
21576 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987996.
21576 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr7.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr8.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 8
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr8
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
21801 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.98906.
21801 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr8.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr8.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr8.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr8.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 8
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr8
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
21801 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.98906.
21801 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr8.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr9.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 9
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr9
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
17717 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.98914.
17717 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr9.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr9.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr9.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr9.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 9
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr9
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
17717 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.98914.
17717 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr9.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr10.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 10
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr10
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
21850 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987086.
21850 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr10.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr10.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr10.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr10.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 10
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr10
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
21850 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987086.
21850 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr10.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr11.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 11
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr11
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
18815 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988807.
18815 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr11.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr11.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr11.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr11.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 11
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr11
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
18815 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988807.
18815 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr11.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr12.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 12
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr12
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
20628 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988454.
20628 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr12.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr12.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr12.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr12.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 12
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr12
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
20628 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988454.
20628 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr12.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr13.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 13
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr13
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
12972 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.989238.
12972 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr13.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr13.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr13.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr13.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 13
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr13
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
12972 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.989238.
12972 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr13.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr14.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 14
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr14
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
12571 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988435.
12571 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr14.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr14.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr14.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr14.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 14
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr14
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
12571 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988435.
12571 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr14.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr15.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 15
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr15
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
11583 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987165.
11583 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr15.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr15.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr15.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr15.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 15
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr15
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
11583 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987165.
11583 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr15.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr16.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 16
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr16
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
12171 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.989208.
12171 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr16.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr16.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr16.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr16.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 16
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr16
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
12171 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.989208.
12171 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr16.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr17.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 17
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr17
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
16447 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.98575.
16447 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr17.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr17.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr17.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr17.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 17
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr17
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
16447 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.98575.
16447 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr17.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr18.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 18
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr18
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
11964 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988584.
11964 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr18.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr18.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr18.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr18.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 18
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr18
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
11964 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.988584.
11964 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr18.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr19.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 19
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr19
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
9964 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.990256.
9964 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr19.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr19.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr19.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr19.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 19
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr19
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
9964 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.990256.
9964 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr19.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr20.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 20
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr20
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
11254 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.989527.
11254 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr20.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr20.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr20.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr20.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 20
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr20
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
11254 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.989527.
11254 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr20.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr21.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 21
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr21
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
5088 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.991762.
5088 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr21.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr21.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr21.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr21.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 21
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr21
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
5088 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.991762.
5088 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr21.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr22.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 22
  --make-bed
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr22
  --real-ref-alleles

62942 MB RAM detected; reserving 31471 MB for main workspace.
7515 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987226.
7515 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
--make-bed to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr22.bed
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr22.bim
+
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr22.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr22.log.
Options in effect:
  --bfile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated
  --chr 22
  --out /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr22
  --real-ref-alleles
  --recode vcf

62942 MB RAM detected; reserving 31471 MB for main workspace.
7515 out of 403267 variants loaded from .bim file.
4365 people (2534 males, 1831 females) loaded from .fam.
4365 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 4365 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.987226.
7515 variants and 4365 people pass filters and QC.
Among remaining phenotypes, 2165 are cases and 2200 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/AGS_Mayo_Oncoarray_for_QC-updated-chr22.vcf
... done.
```


The latest version of the above scripts automatically creates vccf files.
The do still need compressed though.


```BASH
module load htslib/1.10.2

for vcf in *vcf; do
echo $vcf
bgzip $vcf
done
```

That should be good.




##	Upload

Copy the files locally.
```
scp c4:/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210226-prep_for_imputation/*vcf.gz ./
```

Then upload to the web app.




https://imputation.biodatacatalyst.nhlbi.nih.gov/

Login

Run > Genotype Imputation (Minimac4) 1.5.7


Name : 20210227

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


Wait for files to upload.  This took me about 30-45 minutes.


```
Input Validation
```

```
Quality Control
```

```
Quality Control (Report)
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







