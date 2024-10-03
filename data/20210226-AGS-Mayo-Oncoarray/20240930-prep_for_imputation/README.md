
#	20210226-AGS-Mayo-Oncoarray/20240930-prep_for_imputation

PGS Imputation

https://imputationserver.sph.umich.edu/#!run/imputationserver2-pgs


```
wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip
unzip HRC-1000G-check-bim-v4.3.0.zip

wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
```

Problems downloading
```
cp /francislab/data1/working/20240918-MeningiomaGWAS/20240918-prep_for_imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab* ./
```


```
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bed
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bim
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.fam
```

##  Create a frequency file

```BASH
module load plink/1.90b6.26

plink --freq --bfile AGS_Mayo_Oncoarray_for_QC --out AGS_Mayo_Oncoarray_for_QC > plink.create_frequency_file.log
chmod -w AGS_Mayo_Oncoarray_for_QC.frq
```

##  Check BIM and split

Version 4.2.7 DOES NOT CREATE VCF files. I probably could have created them on my own though.

Version 4.3.0 DOES CREATE VCF 

```
perl HRC-1000G-check-bim.pl --bim AGS_Mayo_Oncoarray_for_QC.bim --frequency AGS_Mayo_Oncoarray_for_QC.frq --ref HRC.r1-1.GRCh37.wgs.mac5.sites.tab --hrc > HRC-1000G-check-bim.pl.log
chmod -w HRC-1000G-check-bim.pl.log
```

```
sh Run-plink.sh > Run-plink.sh.log
```







```BASH
module load htslib/1.10.2

for vcf in *vcf; do
echo $vcf
bgzip $vcf
done

chmod a-w *{bim,bed,fam,vcf.gz}
```

That should be good.






##  Upload

Copy the files locally.
```
scp c4:/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20240930-prep_for_imputation/*vcf.gz ./
```

Then upload to the web app.





https://imputationserver.sph.umich.edu/#!run/imputationserver2-pgs



Reference Panel
* 1000G Phase 1 v3 Shapeit2 (no singletons) (GRCh37/hg19)
* 1000G Phase 3 (GRCh38/hg38) pBETA]
* 1000G Phase 3 30x (GRCh38/hg38) [BETA}
* **1000G Phase 3 v5 (GRCh37/hg19)**
* CAAPA African American Panel (GRCh37/hg19)
* Genome Asia Pilot - GAsP (GRCh37/hg19)
* HRC r1.1 2016 (GRCh37/hg19)
* HapMap 2 (GRCh37/hg19)
* Samoan (GRCh37/hg19)


Array Build
* **GRCh37/hg19**
* GRCh38/hg38

rsq Filter
* off
* **0.3**
* 0.8

PGS Calculation


Scores
* **PGS-Catalog v20240318**


Trait Category
* Biological process (39 scoores)
* Body measurement (257 scores)
* Cancer (659 scores)
* Cardiovascular disease (266 scores)
* Cardiovascular measurement (142 sccoores)
* Digestive system disorder (350 scores)
* Hematological measurement (342 scores)
* Immune system disorder (203 scores)
* Inflammatory measurement (46 scores)
* Lipid or lipoprotein measurement (339 scores)
* Liver enzyme measurement (28 scores)
* Metabolic disorder (223 scores)
* Neurological disorder (239 scores)
* Other disease (260 scores)
* Other measurement (1,843 scores)
* Other trait (190 scores)
* Sex-specific PGS (18 scores)
* **All traits (4,489 scores)**



Ancestry Estimation
* Disabled
* **Worldwide (HGDP)**




Server crashed first time and had to reupload




```
Input Validation
22 valid VCF file(s) found.
Samples: 4365
Chromosomes: 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9
SNPs: 403267
Chunks: 154
Datatype: unphased
Build: hg19
Reference Panel: 1000g-phase-3-v5 (hg19)
Population: off
Phasing: eagle
Mode: imputation


Quality Control
Skip allele frequency check.

Calculating QC Statistics

Statistics:
Alternative allele frequency > 0.5 sites: 103,446
Reference Overlap: 99.74 %
Match: 402,184
Allele switch: 0
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
Allele mismatch: 18
SNPs call rate < 90%: 2,538

Excluded sites in total: 2,556
Remaining sites in total: 399,646
See snps-excluded.txt for details
Typed only sites: 1,065
See typed-only.txt for details
Warning: 1 Chunk(s) excluded: < 3 SNPs (see chunks-excluded.txt for details).
Remaining chunk(s): 153

Quality Control Report


Phasing and Imputation
Phasing with Eagle (153/153)

Imputation (153/161)				<---- ?


Ancestry Estimation
Prepare Data (1/1)

Prepare Data (88/98)				<---- ?

Estimate Ancestry

Visualize Ancestry


Polygenic Scores
Trait Category: all
Number of Scores: 0

Calculate Polygenic Scores (153/153)

Merge Polygenic Scores

Analyze Polygenic Scores

Create Ploygenic Score Report

Data have been exported successfully. We have sent a notification email to jakewendt@gmail.com
```





```

mkdir pgs ; cd pgs
curl -sL https://imputationserver.sph.umich.edu/get/XAh0GIVKGQ5TtuEy3d1bXuCvLVs8Rw71yV4gM2nY | bash


```
