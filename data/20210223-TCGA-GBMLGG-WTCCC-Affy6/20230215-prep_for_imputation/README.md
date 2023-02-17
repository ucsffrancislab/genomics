
#       TopMed Imputation

https://imputation.biodatacatalyst.nhlbi.nih.gov/

https://topmedimpute.readthedocs.io/en/latest/


##      Data preparation

The main steps for HRC are:

https://topmedimpute.readthedocs.io/en/latest/prepare-your-data.html




###     Download tool and sites

These are hg38 so not these

```BASH
#wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
#unzip HRC-1000G-check-bim-v4.2.7.zip
#wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
#gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz 
```

https://www.well.ox.ac.uk/~wrayner/tools/

```BASH
wget https://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip
unzip HRC-1000G-check-bim-v4.3.0.zip
```

The TOPMed reference panel is not available for direct download from this site, it needs to be created from the VCF of dbSNP submitted sites (currently ALL.TOPMed_freeze5_hg38_dbSNP.vcf.gz).

Once logged in, there is a command to download on the command line via curl.

https://bravo.sph.umich.edu/freeze5/hg38/download

Something like ...
```BASH
curl 'https://bravo.sph.umich.edu/freeze5/hg38/download/all' -H 'Accept-Encoding: gzip, deflate, br' -H 'Cookie: _ga=GA199999; _gid=GA19; remember_token="me@here.com|ASDFASDFASDF"; _gat_gtag_UA_73910830_2=1' --compressed > bravo-dbsnp-all.vcf.gz
```

~6.4 GB 


```BASH
zgrep -c "PASS" bravo-dbsnp-all.vcf.gz 
463071133
```



```BASH
wget https://www.well.ox.ac.uk/~wrayner/tools/CreateTOPMed.zip
unzip CreateTOPMed.zip
```

This looks like it will take about 20 hours.

```BASH
nohup ./CreateTOPMed.pl -i bravo-dbsnp-all.vcf.gz -o PASS.Variants.bravo-dbsnp-all.tab.gz &
```

Note that this converts the original chr1 to just 1 in the tab file.


```BASH
zcat PASS.Variants.bravo-dbsnp-all.tab.gz | |wc -l
463071133
```




###	Add the chr prefix to the chromosomes



OK. The check bim script requires the chromosomes be numeric. Not sure how that'll work with the reference panel that isn't.....





This dataset does not have the chr prefix which the imputation server says that it needs.

The reference files also have the chr prefix.

I need to add the chr prefix to the data.

I need to convert the bed file to ped/map files, edit, then convert back to bed/bim/fam files.


Convert to ped/map, convert 1-26 to chr1-chrM, limiting to just chr1-22


```
plink --bfile 20230215_TCGA_WTCCC_lifted.hg38.final --recode --out 20230217_TCGA_WTCCC --chr 1-22
chmod -w 20230217_TCGA_WTCCC.{map,ped}
```


Convert back to bed/bim/fam files

Looks like you have to keep the option `--output-chr chrM` here too as default is numeric?

```BASH
plink --file 20230217_TCGA_WTCCC --make-bed --out 20230217_TCGA_WTCCC
chmod -w 20230217_TCGA_WTCCC.{bed,bim,fam}
```


###     Create a frequency file

```BASH
module load plink/1.90b6.21

plink --freq --bfile 20230217_TCGA_WTCCC --out 20230217_TCGA_WTCCC
chmod -w 20230217_TCGA_WTCCC.frq
```


###	Check BIM and split


This script requires the chromosomes be numeric!!!!

```BASH
perl HRC-1000G-check-bim.pl --bim 20230217_TCGA_WTCCC.bim --frequency 20230217_TCGA_WTCCC.frq --ref PASS.Variants.bravo-dbsnp-all.tab.gz --hrc

         Script to check plink .bim files against HRC/1000G for
        strand, id names, positions, alleles, ref/alt assignment
                    William Rayner 2015-2020
                        wrayner@well.ox.ac.uk

                               Version 4.3

Options Set:
Reference Panel:             HRC
Bim filename:                20230216_TCGA_WTCCC.bim
Reference filename:          PASS.Variants.bravo-dbsnp-all.tab.gz
Allele frequencies filename: 20230216_TCGA_WTCCC.frq
Plink executable to use:     plink

Chromosome flag set:         No
Allele frequency threshold:  0.2

Path to plink bim file: /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation

Reading PASS.Variants.bravo-dbsnp-all.tab.gz
Reference Panel is zipped
2000000
4000000
6000000
...

460000000
462000000
463071133
 ...Done


Details written to log file: /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/LOG-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt

Creating variant lists
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Force-Allele1-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Strand-Flip-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/ID-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Position-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Chromosome-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Exclude-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/FreqPlot-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt


Matching to HRC

Position Matches
 ID matches HRC 0
 ID Doesn't match HRC 742436
 Total Position Matches 742436
ID Match
 Position different from HRC 0
No Match to HRC 9236
Skipped (MT) 17
Total in bim file 751689
Total processed 751689

Indels 0

SNPs not changed 132294
SNPs to change ref alt 494914
Strand ok 403122
Total Strand ok 627208

Strand to change 309130
Total checked 742436
Total checked Strand 712252
Total removed for allele Frequency diff > 0.2 48850
Palindromic SNPs with Freq > 0.4 16677


Non Matching alleles 13507
ID and allele mismatching 13507; where HRC is . 0
Duplicates removed 0


Writing plink commands to: Run-plink.sh
```




**Not sure if `ID matches HRC 0` is ok.**








In order to add the apparently needed chr prefix, the script will need an option added to each plink call.

```BASH
sed -i '/^plink/s/$/ --output-chr chrM/' Run-plink.sh
```





This includes chr23 (X) which I can just ignore later



```BASH
bash Run-plink.sh



PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP1.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final
  --exclude /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Exclude-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP1
  --output-chr chrM

515812 MB RAM detected; reserving 257906 MB for main workspace.
751689 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
--exclude: 663402 variants remaining.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Warning: 12105 het. haploid genotypes present (see
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP1.hh
); many commands treat these as missing.
Total genotyping rate is 0.818706.
663402 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP1.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP1.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP1.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP2.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP1
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP2
  --output-chr chrM
  --update-chr
  --update-map /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Chromosome-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt

Note: --update-map <filename> + parameter-free --update-chr deprecated.  Use
--update-chr <filename> instead.
515812 MB RAM detected; reserving 257906 MB for main workspace.
663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Warning: 12105 het. haploid genotypes present (see
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP2.hh
); many commands treat these as missing.
Total genotyping rate is 0.818706.
663402 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--update-chr: 0 values updated.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP2.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP2.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP2.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP3.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP2
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP3
  --output-chr chrM
  --update-map /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Position-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt

515812 MB RAM detected; reserving 257906 MB for main workspace.
663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
--update-map: 0 values updated.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Warning: 12105 het. haploid genotypes present (see
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP3.hh
); many commands treat these as missing.
Total genotyping rate is 0.818706.
663402 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP3.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP3.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP3.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP4.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP3
  --flip /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Strand-Flip-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP4
  --output-chr chrM

515812 MB RAM detected; reserving 257906 MB for main workspace.
663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
--flip: 307760 SNPs flipped, 1370 SNP IDs not present.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Warning: 12105 het. haploid genotypes present (see
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP4.hh
); many commands treat these as missing.
Total genotyping rate is 0.818706.
663402 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP4.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP4.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP4.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated.log.
Options in effect:
  --a2-allele /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/Force-Allele1-20230215_TCGA_WTCCC_lifted.hg38.final-HRC.txt
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/TEMP4
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --output-chr chrM

515812 MB RAM detected; reserving 257906 MB for main workspace.
663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Warning: 12105 het. haploid genotypes present (see
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated.hh
); many commands treat these as missing.
Total genotyping rate is 0.818706.
--a2-allele: 663402 assignments made.
663402 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr1.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 1
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr1
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
54811 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.784302.
54811 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr1.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr1.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr1.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr1.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 1
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr1
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
54811 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.784302.
54811 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr1.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr2.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 2
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr2
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
59486 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.789151.
59486 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr2.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr2.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr2.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr2.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 2
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr2
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
59486 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.789151.
59486 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr2.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr3.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 3
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr3
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
48365 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.848973.
48365 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr3.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr3.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr3.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr3.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 3
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr3
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
48365 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.848973.
48365 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr3.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr4.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 4
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr4
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
44022 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.846643.
44022 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr4.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr4.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr4.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr4.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 4
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr4
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
44022 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.846643.
44022 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr4.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr5.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 5
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr5
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
45274 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.861989.
45274 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr5.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr5.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr5.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr5.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 5
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr5
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
45274 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.861989.
45274 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr5.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr6.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 6
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr6
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
44196 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.862466.
44196 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr6.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr6.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr6.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr6.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 6
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr6
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
44196 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.862466.
44196 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr6.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr7.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 7
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr7
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
31149 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.841505.
31149 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr7.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr7.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr7.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr7.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 7
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr7
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
31149 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.841505.
31149 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr7.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr8.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 8
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr8
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
38078 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.852296.
38078 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr8.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr8.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr8.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr8.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 8
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr8
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
38078 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.852296.
38078 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr8.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr9.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 9
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr9
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
29895 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.857128.
29895 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr9.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr9.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr9.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr9.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 9
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr9
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
29895 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.857128.
29895 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr9.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr10.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 10
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr10
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
28757 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.762889.
28757 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr10.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr10.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr10.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr10.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 10
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr10
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
28757 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.762889.
28757 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr10.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr11.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 11
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr11
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
35089 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.791557.
35089 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr11.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr11.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr11.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr11.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 11
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr11
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
35089 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.791557.
35089 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr11.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr12.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 12
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr12
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
33288 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.799953.
33288 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr12.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr12.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr12.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr12.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 12
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr12
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
33288 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.799953.
33288 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr12.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr13.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 13
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr13
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
25912 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.779033.
25912 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr13.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr13.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr13.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr13.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 13
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr13
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
25912 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.779033.
25912 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr13.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr14.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 14
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr14
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
21350 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.786078.
21350 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr14.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr14.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr14.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr14.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 14
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr14
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
21350 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.786078.
21350 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr14.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr15.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 15
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr15
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
20184 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.78849.
20184 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr15.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr15.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr15.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr15.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 15
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr15
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
20184 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.78849.
20184 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr15.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr16.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 16
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr16
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
21250 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.792067.
21250 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr16.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr16.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr16.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr16.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 16
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr16
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
21250 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.792067.
21250 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr16.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr17.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 17
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr17
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
16105 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.796642.
16105 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr17.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr17.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr17.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr17.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 17
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr17
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
16105 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.796642.
16105 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr17.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr18.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 18
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr18
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
20868 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.777569.
20868 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr18.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr18.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr18.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr18.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 18
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr18
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
20868 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.777569.
20868 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr18.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr19.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 19
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr19
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
8271 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.822057.
8271 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr19.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr19.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr19.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr19.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 19
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr19
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
8271 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.822057.
8271 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr19.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr20.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 20
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr20
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
18587 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.845568.
18587 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr20.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr20.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr20.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr20.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 20
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr20
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
18587 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.845568.
18587 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr20.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr21.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 21
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr21
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
9803 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.858583.
9803 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr21.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr21.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr21.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr21.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 21
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr21
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
9803 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.858583.
9803 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr21.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr22.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 22
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr22
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
8642 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.853343.
8642 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr22.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr22.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr22.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr22.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 22
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr22
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
8642 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.853343.
8642 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr22.vcf
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 23
  --make-bed
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23
  --output-chr chrM
  --real-ref-alleles

515812 MB RAM detected; reserving 257906 MB for main workspace.
20 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Warning: 12105 het. haploid genotypes present (see
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23.hh
); many commands treat these as missing.
Total genotyping rate is 0.696717.
20 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
--make-bed to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23.bed
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23.bim
+
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23.fam
... done.
PLINK v1.90b6.21 64-bit (19 Oct 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23.log.
Options in effect:
  --bfile /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated
  --chr 23
  --out /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23
  --output-chr chrM
  --real-ref-alleles
  --recode vcf

515812 MB RAM detected; reserving 257906 MB for main workspace.
20 out of 663402 variants loaded from .bim file.
6656 people (3810 males, 2846 females) loaded from .fam.
6656 phenotype values loaded from .fam.
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 6656 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Warning: 12105 het. haploid genotypes present (see
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23.hh
); many commands treat these as missing.
Total genotyping rate is 0.696717.
20 variants and 6656 people pass filters and QC.
Among remaining phenotypes, 0 are cases and 6656 are controls.
Warning: Underscore(s) present in sample IDs.
--recode vcf to
/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23.vcf
... done.

```


###     Create vcf files using plink

Looks like new versions of the script do this already

```BASH
#for bed in 20230216_TCGA_WTCCC-updated-chr*.bed ; do
#base=${bed%.bed}
#plink --bfile ${base} --recode vcf --out ${base}
#done
```


```BASH
module load htslib/1.10.2
for vcf in 20230215_TCGA_WTCCC_lifted.hg38.final-updated*vcf; do
echo $vcf
bgzip $vcf
done
```



###	Check VCF files


CheckVCF

Use checkVCF to ensure that the VCF files are valid. checkVCF proposes "Action Items" (e.g. upload to sftp server), which can be ignored. Only the validity should be checked with this command.


```BASH
wget https://raw.githubusercontent.com/zhanxw/checkVCF/master/checkVCF.py
chmod +x checkVCF.py
```


This produces a lot of ...

[ 20 ] Inconsistent reference sites are outputted to [ 20230215_TCGA_WTCCC_lifted.hg38.final-updated-chr23.vcf.gz.out.check.ref ]

basically for every position?

```BASH
for vcf in *TCGA_WTCCC*vcf.gz; do
echo $vcf
./checkVCF.py -r /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa.gz -o ${vcf}.out $vcf
done
```

I'm not sure if this is actually true.

```
MismatchRefBase	chrX:102615935:-T/G
MismatchRefBase	chrX:135687823:-C/T
MismatchRefBase	chrX:140998510:-T/C
MismatchRefBase	chrX:141777467:-T/C
[gwendt@c4-dev2 /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation]$ samtools faidx /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa chrX:141777467-141777467
>chrX:141777467-141777467
t
[gwendt@c4-dev2 /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation]$ samtools faidx /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa chrX:140998510-140998510
>chrX:140998510-140998510
t
[gwendt@c4-dev2 /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation]$ samtools faidx /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa chrX:135687823-135687823
>chrX:135687823-135687823
c
[gwendt@c4-dev2 /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation]$ samtools faidx /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa chrX:102615935-102615935
>chrX:102615935-102615935
T
```







##      Upload

Copy the files locally.

```BASH
rsync -avz --progress --include="*TCGA_WTCCC*updated*vcf.gz" --exclude="*" c4:/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/ ./
```

Then upload to the web app.











https://imputation.biodatacatalyst.nhlbi.nih.gov/

Login

Run > Genotype Imputation (Minimac4) 1.6.6


Name : 20230216

Reference Panel : 
* **TOPMed r2** (only option)

Input Files : File Upload (selected my local copies for upload)

Array build : 
* GRCh37/hg19
* **GRCh38/hg38**

rsq Filter : 
* off
* 0.001
* **0.1**
* 0.2
* 0.3

Phasing : 
* **Eagle v2.4 (unphased input)**
* No phasing (phased input)

Population :
* **vs TOPMed Panel**
* Skip

Mode : 
* **Quality Control and Imputation**
* Quality Control and Phasing Only
* Quality Control Only

O - AES 256 encryption  (seems unnecessary)

X - **Generate Meta-imputation file**   (I don't recall this option previously)

**Submit Job**






Started at 11:37am
Wait for files to upload.  This took me about .....
Single VCF and hg38 without chr prefix. Expecting failure.




Trying again...







