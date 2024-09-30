
#	20210302-AGS-illumina/20240930-prep_for_imputation

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
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bed
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bim
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.fam
```

##  Create a frequency file

```BASH
module load plink/1.90b6.26

plink --freq --bfile AGS_illumina_for_QC --out AGS_illumina_for_QC > plink.create_frequency_file.log
chmod -w AGS_illumina_for_QC.frq
```

##  Check BIM and split

Version 4.2.7 DOES NOT CREATE VCF files. I probably could have created them on my own though.

Version 4.3.0 DOES CREATE VCF 

```
perl HRC-1000G-check-bim.pl --bim AGS_illumina_for_QC.bim --frequency AGS_illumina_for_QC.frq --ref HRC.r1-1.GRCh37.wgs.mac5.sites.tab --hrc > HRC-1000G-check-bim.pl.log
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
scp c4:/francislab/data1/working/20210302-AGS-illumina/20240930-prep_for_imputation/*vcf.gz ./
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









