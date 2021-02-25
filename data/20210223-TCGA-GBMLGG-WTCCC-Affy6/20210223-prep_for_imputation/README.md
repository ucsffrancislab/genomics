
#	TopMed Imputation

https://imputation.biodatacatalyst.nhlbi.nih.gov/

https://topmedimpute.readthedocs.io/en/latest/


##	Data preparation

The main steps for HRC are:

https://topmedimpute.readthedocs.io/en/latest/prepare-your-data/


###	Download tool and sites

```BASH
wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
unzip HRC-1000G-check-bim-v4.2.7.zip
wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz 
```

###	Convert ped/map to bed

I have `bed` files so shouldn't need this.
```BASH
plink --file <input-file> --make-bed --out <output-file>
```

###	Create a frequency file

```BASH
module load plink/1.90b6.21

plink --freq --bfile TCGA_WTCCC_for_QC --out TCGA_WTCCC_for_QC
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC
  --freq
  --out TCGA_WTCCC_for_QC

386796 MB RAM detected; reserving 193398 MB for main workspace.
733799 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.848166.
--freq: Allele frequencies (founders only) written to TCGA_WTCCC_for_QC.frq .
```

###	Execute script

```BASH
perl HRC-1000G-check-bim.pl -b TCGA_WTCCC_for_QC.bim -f TCGA_WTCCC_for_QC.frq -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h


                                       Script to check plink .bim files against HRC/1000G for
                                      strand, id names, positions, alleles, ref/alt assignment
                                                       William Rayner 2015
                                                      wrayner@well.ox.ac.uk

                                                           Version 4.2.7


Options Set:
Reference Panel:             HRC
Bim filename:                TCGA_WTCCC_for_QC.bim
Reference filename:          HRC.r1-1.GRCh37.wgs.mac5.sites.tab
Allele frequencies filename: TCGA_WTCCC_for_QC.frq
Allele frequency threshold:  0.2


Reading HRC.r1-1.GRCh37.wgs.mac5.sites.tab
 100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000 1500000 1600000 1700000 1800000 1900000 2000000 2100000 2200000 2300000 2400000 2500000 2600000 2700000 2800000 2900000 3000000 3100000 3200000 3300000 3400000 3500000 3600000 3700000 3800000 3900000 4000000 4100000 4200000 4300000 4400000 4500000 4600000 4700000 4800000 4900000 5000000 5100000 5200000 5300000 5400000 5500000 5600000 5700000 5800000 5900000 6000000 6100000 6200000 6300000 6400000 6500000 6600000 6700000 6800000 6900000 7000000 7100000 7200000 7300000 7400000 7500000 7600000 7700000 7800000 7900000 8000000 8100000 8200000 8300000 8400000 8500000 8600000 8700000 8800000 8900000 9000000 9100000 9200000 9300000 9400000 9500000 9600000 9700000 9800000 9900000 10000000 10100000 10200000 10300000 10400000 10500000 10600000 10700000 10800000 10900000 11000000 11100000 11200000 11300000 11400000 11500000 11600000 11700000 11800000 11900000 12000000 12100000 12200000 12300000 12400000 12500000 12600000 12700000 12800000 12900000 13000000 13100000 13200000 13300000 13400000 13500000 13600000 13700000 13800000 13900000 14000000 14100000 14200000 14300000 14400000 14500000 14600000 14700000 14800000 14900000 15000000 15100000 15200000 15300000 15400000 15500000 15600000 15700000 15800000 15900000 16000000 16100000 16200000 16300000 16400000 16500000 16600000 16700000 16800000 16900000 17000000 17100000 17200000 17300000 17400000 17500000 17600000 17700000 17800000 17900000 18000000 18100000 18200000 18300000 18400000 18500000 18600000 18700000 18800000 18900000 19000000 19100000 19200000 19300000 19400000 19500000 19600000 19700000 19800000 19900000 20000000 20100000 20200000 20300000 20400000 20500000 20600000 20700000 20800000 20900000 21000000 21100000 21200000 21300000 21400000 21500000 21600000 21700000 21800000 21900000 22000000 22100000 22200000 22300000 22400000 22500000 22600000 22700000 22800000 22900000 23000000 23100000 23200000 23300000 23400000 23500000 23600000 23700000 23800000 23900000 24000000 24100000 24200000 24300000 24400000 24500000 24600000 24700000 24800000 24900000 25000000 25100000 25200000 25300000 25400000 25500000 25600000 25700000 25800000 25900000 26000000 26100000 26200000 26300000 26400000 26500000 26600000 26700000 26800000 26900000 27000000 27100000 27200000 27300000 27400000 27500000 27600000 27700000 27800000 27900000 28000000 28100000 28200000 28300000 28400000 28500000 28600000 28700000 28800000 28900000 29000000 29100000 29200000 29300000 29400000 29500000 29600000 29700000 29800000 29900000 30000000 30100000 30200000 30300000 30400000 30500000 30600000 30700000 30800000 30900000 31000000 31100000 31200000 31300000 31400000 31500000 31600000 31700000 31800000 31900000 32000000 32100000 32200000 32300000 32400000 32500000 32600000 32700000 32800000 32900000 33000000 33100000 33200000 33300000 33400000 33500000 33600000 33700000 33800000 33900000 34000000 34100000 34200000 34300000 34400000 34500000 34600000 34700000 34800000 34900000 35000000 35100000 35200000 35300000 35400000 35500000 35600000 35700000 35800000 35900000 36000000 36100000 36200000 36300000 36400000 36500000 36600000 36700000 36800000 36900000 37000000 37100000 37200000 37300000 37400000 37500000 37600000 37700000 37800000 37900000 38000000 38100000 38200000 38300000 38400000 38500000 38600000 38700000 38800000 38900000 39000000 39100000 39200000 39300000 39400000 39500000 39600000 39700000 39800000 39900000 40000000 40100000 40200000 40300000 40400000 Done
Matching to HRC

Position Matches
 ID matches HRC 731705
 ID Doesn't match HRC 1254
 Total Position Matches 732959
ID Match
 Different position to HRC 0
No Match to HRC 840
Skipped (X, XY, Y, MT) 0
Total in bim file 733799
Total processed 733799

Indels (ignored in r1) 0

SNPs not changed 132390
SNPs to change ref alt 497927
Strand ok 404890
Total Strand ok 630317

Strand to change 310014
Total checked 732959
Total checked Strand 714904
Total removed for allele Frequency diff > 0.2 61856
Palindromic SNPs with Freq > 0.4 16165


Non Matching alleles 1890
ID and allele mismatching 1113; where HRC is . 1112
Duplicates removed 0





sh Run-plink.sh

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TEMP1.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC
  --exclude Exclude-TCGA_WTCCC_for_QC-HRC.txt
  --make-bed
  --out TEMP1

386796 MB RAM detected; reserving 193398 MB for main workspace.
733799 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
--exclude: 653048 variants remaining.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.86551.
653048 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TEMP1.bed + TEMP1.bim + TEMP1.fam ... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TEMP2.log.
Options in effect:
  --bfile TEMP1
  --make-bed
  --out TEMP2
  --update-chr
  --update-map Chromosome-TCGA_WTCCC_for_QC-HRC.txt

Note: --update-map <filename> + parameter-free --update-chr deprecated.  Use
--update-chr <filename> instead.
386796 MB RAM detected; reserving 193398 MB for main workspace.
653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.86551.
653048 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--update-chr: 0 values updated.
--make-bed to TEMP2.bed + TEMP2.bim + TEMP2.fam ... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TEMP3.log.
Options in effect:
  --bfile TEMP2
  --make-bed
  --out TEMP3
  --update-map Position-TCGA_WTCCC_for_QC-HRC.txt

386796 MB RAM detected; reserving 193398 MB for main workspace.
653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
--update-map: 0 values updated.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.86551.
653048 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TEMP3.bed + TEMP3.bim + TEMP3.fam ... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TEMP4.log.
Options in effect:
  --bfile TEMP3
  --flip Strand-Flip-TCGA_WTCCC_for_QC-HRC.txt
  --make-bed
  --out TEMP4

386796 MB RAM detected; reserving 193398 MB for main workspace.
653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
--flip: 303360 SNPs flipped, 6654 SNP IDs not present.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.86551.
653048 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TEMP4.bed + TEMP4.bim + TEMP4.fam ... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TEMP4
  --make-bed
  --out TCGA_WTCCC_for_QC-updated

386796 MB RAM detected; reserving 193398 MB for main workspace.
653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.86551.
--a1-allele: 653048 assignments made.
653048 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated.bed + TCGA_WTCCC_for_QC-updated.bim +
TCGA_WTCCC_for_QC-updated.fam ... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr1.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 1
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr1

386796 MB RAM detected; reserving 193398 MB for main workspace.
52043 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.856514.
--a1-allele: 52043 assignments made.
52043 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr1.bed +
TCGA_WTCCC_for_QC-updated-chr1.bim + TCGA_WTCCC_for_QC-updated-chr1.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr2.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 2
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr2

386796 MB RAM detected; reserving 193398 MB for main workspace.
56267 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.857119.
--a1-allele: 56267 assignments made.
56267 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr2.bed +
TCGA_WTCCC_for_QC-updated-chr2.bim + TCGA_WTCCC_for_QC-updated-chr2.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr3.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 3
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr3

386796 MB RAM detected; reserving 193398 MB for main workspace.
48762 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.867175.
--a1-allele: 48762 assignments made.
48762 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr3.bed +
TCGA_WTCCC_for_QC-updated-chr3.bim + TCGA_WTCCC_for_QC-updated-chr3.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr4.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 4
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr4

386796 MB RAM detected; reserving 193398 MB for main workspace.
44471 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.863135.
--a1-allele: 44471 assignments made.
44471 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr4.bed +
TCGA_WTCCC_for_QC-updated-chr4.bim + TCGA_WTCCC_for_QC-updated-chr4.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr5.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 5
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr5

386796 MB RAM detected; reserving 193398 MB for main workspace.
45741 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.876963.
--a1-allele: 45741 assignments made.
45741 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr5.bed +
TCGA_WTCCC_for_QC-updated-chr5.bim + TCGA_WTCCC_for_QC-updated-chr5.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr6.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 6
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr6

386796 MB RAM detected; reserving 193398 MB for main workspace.
44625 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.880583.
--a1-allele: 44625 assignments made.
44625 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr6.bed +
TCGA_WTCCC_for_QC-updated-chr6.bim + TCGA_WTCCC_for_QC-updated-chr6.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr7.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 7
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr7

386796 MB RAM detected; reserving 193398 MB for main workspace.
32505 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.860657.
--a1-allele: 32505 assignments made.
32505 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr7.bed +
TCGA_WTCCC_for_QC-updated-chr7.bim + TCGA_WTCCC_for_QC-updated-chr7.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr8.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 8
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr8

386796 MB RAM detected; reserving 193398 MB for main workspace.
38904 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.871448.
--a1-allele: 38904 assignments made.
38904 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr8.bed +
TCGA_WTCCC_for_QC-updated-chr8.bim + TCGA_WTCCC_for_QC-updated-chr8.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr9.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 9
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr9

386796 MB RAM detected; reserving 193398 MB for main workspace.
30787 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.877243.
--a1-allele: 30787 assignments made.
30787 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr9.bed +
TCGA_WTCCC_for_QC-updated-chr9.bim + TCGA_WTCCC_for_QC-updated-chr9.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr10.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 10
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr10

386796 MB RAM detected; reserving 193398 MB for main workspace.
27412 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.847638.
--a1-allele: 27412 assignments made.
27412 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr10.bed +
TCGA_WTCCC_for_QC-updated-chr10.bim + TCGA_WTCCC_for_QC-updated-chr10.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr11.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 11
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr11

386796 MB RAM detected; reserving 193398 MB for main workspace.
33292 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.865061.
--a1-allele: 33292 assignments made.
33292 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr11.bed +
TCGA_WTCCC_for_QC-updated-chr11.bim + TCGA_WTCCC_for_QC-updated-chr11.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr12.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 12
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr12

386796 MB RAM detected; reserving 193398 MB for main workspace.
31843 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.873046.
--a1-allele: 31843 assignments made.
31843 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr12.bed +
TCGA_WTCCC_for_QC-updated-chr12.bim + TCGA_WTCCC_for_QC-updated-chr12.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr13.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 13
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr13

386796 MB RAM detected; reserving 193398 MB for main workspace.
24502 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.861049.
--a1-allele: 24502 assignments made.
24502 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr13.bed +
TCGA_WTCCC_for_QC-updated-chr13.bim + TCGA_WTCCC_for_QC-updated-chr13.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr14.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 14
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr14

386796 MB RAM detected; reserving 193398 MB for main workspace.
20150 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.869858.
--a1-allele: 20150 assignments made.
20150 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr14.bed +
TCGA_WTCCC_for_QC-updated-chr14.bim + TCGA_WTCCC_for_QC-updated-chr14.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr15.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 15
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr15

386796 MB RAM detected; reserving 193398 MB for main workspace.
19392 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.859302.
--a1-allele: 19392 assignments made.
19392 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr15.bed +
TCGA_WTCCC_for_QC-updated-chr15.bim + TCGA_WTCCC_for_QC-updated-chr15.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr16.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 16
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr16

386796 MB RAM detected; reserving 193398 MB for main workspace.
20706 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.852902.
--a1-allele: 20706 assignments made.
20706 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr16.bed +
TCGA_WTCCC_for_QC-updated-chr16.bim + TCGA_WTCCC_for_QC-updated-chr16.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr17.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 17
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr17

386796 MB RAM detected; reserving 193398 MB for main workspace.
15610 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.86603.
--a1-allele: 15610 assignments made.
15610 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr17.bed +
TCGA_WTCCC_for_QC-updated-chr17.bim + TCGA_WTCCC_for_QC-updated-chr17.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr18.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 18
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr18

386796 MB RAM detected; reserving 193398 MB for main workspace.
19778 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.856305.
--a1-allele: 19778 assignments made.
19778 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr18.bed +
TCGA_WTCCC_for_QC-updated-chr18.bim + TCGA_WTCCC_for_QC-updated-chr18.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr19.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 19
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr19

386796 MB RAM detected; reserving 193398 MB for main workspace.
8514 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.868219.
--a1-allele: 8514 assignments made.
8514 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr19.bed +
TCGA_WTCCC_for_QC-updated-chr19.bim + TCGA_WTCCC_for_QC-updated-chr19.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr20.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 20
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr20

386796 MB RAM detected; reserving 193398 MB for main workspace.
18655 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.865243.
--a1-allele: 18655 assignments made.
18655 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr20.bed +
TCGA_WTCCC_for_QC-updated-chr20.bim + TCGA_WTCCC_for_QC-updated-chr20.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr21.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 21
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr21

386796 MB RAM detected; reserving 193398 MB for main workspace.
10172 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.875203.
--a1-allele: 10172 assignments made.
10172 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr21.bed +
TCGA_WTCCC_for_QC-updated-chr21.bim + TCGA_WTCCC_for_QC-updated-chr21.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr22.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 22
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr22

386796 MB RAM detected; reserving 193398 MB for main workspace.
8917 out of 653048 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.872139.
--a1-allele: 8917 assignments made.
8917 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
--make-bed to TCGA_WTCCC_for_QC-updated-chr22.bed +
TCGA_WTCCC_for_QC-updated-chr22.bim + TCGA_WTCCC_for_QC-updated-chr22.fam ...
done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr23.log.
Options in effect:
  --a1-allele Force-Allele1-TCGA_WTCCC_for_QC-HRC.txt
  --bfile TCGA_WTCCC_for_QC-updated
  --chr 23
  --make-bed
  --out TCGA_WTCCC_for_QC-updated-chr23

386796 MB RAM detected; reserving 193398 MB for main workspace.
Error: All variants excluded.
```

Ends with an Error? Hmm. I think that this doesn't include X and Y, so I think we're good.


###	Create vcf using VcfCooker

```BASH
vcfCooker --in-bfile <bim file> --ref <reference.fasta>  --out <output-vcf> --write-vcf
bgzip <output-vcf>
```
Why vcfCooker? Why not plink? vcfCooker is part of a pain in a$$ gotcloud toolkit.
Does vcfCooker do something that plink won't?
Pass.


###	Create vcf files using plink

```BASH
for bed in TCGA_WTCCC_for_QC-updated-chr*.bed ; do
base=${bed%.bed}
plink --bfile ${base} --recode vcf --out ${base}
done

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr10.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr10
  --out TCGA_WTCCC_for_QC-updated-chr10
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
27412 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.847638.
27412 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr10.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr11.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr11
  --out TCGA_WTCCC_for_QC-updated-chr11
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
33292 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.865061.
33292 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr11.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr12.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr12
  --out TCGA_WTCCC_for_QC-updated-chr12
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
31843 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.873046.
31843 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr12.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr13.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr13
  --out TCGA_WTCCC_for_QC-updated-chr13
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
24502 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.861049.
24502 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr13.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr14.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr14
  --out TCGA_WTCCC_for_QC-updated-chr14
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
20150 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.869858.
20150 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr14.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr15.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr15
  --out TCGA_WTCCC_for_QC-updated-chr15
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
19392 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.859302.
19392 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr15.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr16.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr16
  --out TCGA_WTCCC_for_QC-updated-chr16
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
20706 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.852902.
20706 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr16.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr17.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr17
  --out TCGA_WTCCC_for_QC-updated-chr17
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
15610 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.86603.
15610 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr17.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr18.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr18
  --out TCGA_WTCCC_for_QC-updated-chr18
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
19778 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.856305.
19778 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr18.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr19.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr19
  --out TCGA_WTCCC_for_QC-updated-chr19
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
8514 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.868219.
8514 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr19.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr1.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr1
  --out TCGA_WTCCC_for_QC-updated-chr1
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
52043 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.856514.
52043 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr1.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr20.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr20
  --out TCGA_WTCCC_for_QC-updated-chr20
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
18655 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.865243.
18655 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr20.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr21.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr21
  --out TCGA_WTCCC_for_QC-updated-chr21
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
10172 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.875203.
10172 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr21.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr22.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr22
  --out TCGA_WTCCC_for_QC-updated-chr22
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
8917 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.872139.
8917 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr22.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr2.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr2
  --out TCGA_WTCCC_for_QC-updated-chr2
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
56267 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.857119.
56267 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr2.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr3.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr3
  --out TCGA_WTCCC_for_QC-updated-chr3
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
48762 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.867175.
48762 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr3.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr4.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr4
  --out TCGA_WTCCC_for_QC-updated-chr4
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
44471 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.863135.
44471 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr4.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr5.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr5
  --out TCGA_WTCCC_for_QC-updated-chr5
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
45741 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.876963.
45741 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr5.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr6.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr6
  --out TCGA_WTCCC_for_QC-updated-chr6
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
44625 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.880583.
44625 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr6.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr7.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr7
  --out TCGA_WTCCC_for_QC-updated-chr7
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
32505 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.860657.
32505 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr7.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr8.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr8
  --out TCGA_WTCCC_for_QC-updated-chr8
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
38904 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.871448.
38904 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr8.vcf ... done.

PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to TCGA_WTCCC_for_QC-updated-chr9.log.
Options in effect:
  --bfile TCGA_WTCCC_for_QC-updated-chr9
  --out TCGA_WTCCC_for_QC-updated-chr9
  --recode vcf

386796 MB RAM detected; reserving 193398 MB for main workspace.
30787 variants loaded from .bim file.
6716 people (3820 males, 2896 females) loaded from .fam.
6716 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6716 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.877243.
30787 variants and 6716 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6716 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to TCGA_WTCCC_for_QC-updated-chr9.vcf ... done.
```

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
scp c4:/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20210223-prep_for_imputation/*vcf.gz ./
```

Then upload to the web app.




https://imputation.biodatacatalyst.nhlbi.nih.gov/

Login

Run > Genotype Imputation (Minimac4) 1.5.7


Name : 20210225

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
22 valid VCF file(s) found.

Samples: 6716
Chromosomes: 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9
SNPs: 653048
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
Alternative allele frequency > 0.5 sites: 0
Reference Overlap: 99.70 %
Match: 473,576
Allele switch: 165,654
Strand flip: 0
Strand flip and allele switch: 0
A/T, C/G genotypes: 11,389
Filtered sites:
Filter flag set: 0
Invalid alleles: 0
Multiallelic sites: 0
Duplicated sites: 0
NonSNP sites: 0
Monomorphic sites: 0
Allele mismatch: 176
SNPs call rate < 90%: 85,606

Excluded sites in total: 85,782
Remaining sites in total: 565,013
See snps-excluded.txt for details
Typed only sites: 1,940
See typed-only.txt for details

Warning: 1 Chunk(s) excluded: < 3 SNPs (see chunks-excluded.txt for details).
Warning: 6 Chunk(s) excluded: at least one sample has a call rate < 50.0% (see chunks-excluded.txt for details).
Warning: 1 Chunk(s) excluded: reference overlap < 20.0% (see chunks-excluded.txt for details).
Remaining chunk(s): 285
```

```
Quality Control (Report)
Execution successful.
```

Then wait for the process. Started 20210225 @ 8:45AM MST








