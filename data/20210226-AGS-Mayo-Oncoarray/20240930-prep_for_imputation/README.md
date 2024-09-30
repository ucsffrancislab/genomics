
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





