
#	Imputation



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



