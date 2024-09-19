
#	20240918-MeningiomaGWAS/20240918-prep_for_imputation


https://topmedimpute.readthedocs.io/en/latest/

https://imputationserver.readthedocs.io/en/latest/prepare-your-data/


If your input data is GRCh37/hg19 please ensure chromosomes are encoded without prefix (e.g. 20).


more ../../20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/README.md 


```
#wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip

wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip
unzip HRC-1000G-check-bim-v4.3.0.zip

wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
gunzip HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
```




```
ln -s /francislab/data1/raw/20240918-MeningiomaGWAS/MENINGIOMA_GWAS_SHARED.bed
ln -s /francislab/data1/raw/20240918-MeningiomaGWAS/MENINGIOMA_GWAS_SHARED.bim
ln -s /francislab/data1/raw/20240918-MeningiomaGWAS/MENINGIOMA_GWAS_SHARED.fam
```


##	Create a frequency file

```BASH
module load plink/1.90b6.26

plink --freq --bfile MENINGIOMA_GWAS_SHARED --out MENINGIOMA_GWAS_SHARED > plink.create_frequency_file.log
chmod -w MENINGIOMA_GWAS_SHARED.frq
```

##	Check BIM and split

Version 4.2.7 DOES NOT CREATE VCF files. I probably could have created them on my own though.

Version 4.3.0 DOES CREATE VCF

```
perl HRC-1000G-check-bim.pl --bim MENINGIOMA_GWAS_SHARED.bim --frequency MENINGIOMA_GWAS_SHARED.frq --ref HRC.r1-1.GRCh37.wgs.mac5.sites.tab --hrc > HRC-1000G-check-bim.pl.log
```

```
sh Run-plink.sh > Run-plink.sh.log
```


