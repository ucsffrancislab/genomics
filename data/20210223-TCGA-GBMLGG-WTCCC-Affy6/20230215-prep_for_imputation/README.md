
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

```
wget https://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip
unzip HRC-1000G-check-bim-v4.3.0.zip
```

The TOPMed reference panel is not available for direct download from this site, it needs to be created from the VCF of dbSNP submitted sites (currently ALL.TOPMed_freeze5_hg38_dbSNP.vcf.gz).

Once logged in, there is a command to download on the command line via curl.

https://bravo.sph.umich.edu/freeze5/hg38/download

Something like ...
```
curl 'https://bravo.sph.umich.edu/freeze5/hg38/download/all' -H 'Accept-Encoding: gzip, deflate, br' -H 'Cookie: _ga=GA199999; _gid=GA19; remember_token="me@here.com|ASDFASDFASDF"; _gat_gtag_UA_73910830_2=1' --compressed > bravo-dbsnp-all.vcf.gz
```

~6.4 GB 


```BASH
zgrep -c "PASS" bravo-dbsnp-all.vcf.gz 
463071133
```



```
wget https://www.well.ox.ac.uk/~wrayner/tools/CreateTOPMed.zip
unzip CreateTOPMed.zip
```

This looks like it will take about 20 hours.

```
nohup ./CreateTOPMed.pl -i bravo-dbsnp-all.vcf.gz -o PASS.Variants.bravo-dbsnp-all.tab.gz &
```


```
zcat PASS.Variants.bravo-dbsnp-all.tab.gz | |wc -l
463071133
```




###	Add the chr prefix to the chromosomes

This dataset does not have the chr prefix which the imputation server says that it needs.

The reference files also have the chr prefix.

I need to add the chr prefix to the data.

I need to convert the bed file to ped/map files, edit, then convert back to bed/bim/fam files.


Convert to ped/map, convert 1-26 to chr1-chrM, limiting to just chr1-22


```
plink --bfile 20230215_TCGA_WTCCC_lifted.hg38.final --recode --out 20230216_TCGA_WTCCC --output-chr chrM --chr 1-22
chmod -w 20230216_TCGA_WTCCC.{map,ped}
```


Convert back to bed/bim/fam files

```
plink --file 20230216_TCGA_WTCCC --make-bed --out 20230216_TCGA_WTCCC
chmod -w 20230216_TCGA_WTCCC.{bed,bim,fam}
```


###     Create a frequency file

```BASH
module load plink/1.90b6.21

plink --freq --bfile 20230216_TCGA_WTCCC --out 20230216_TCGA_WTCCC
chmod -w 20230216_TCGA_WTCCC.frq
```


###	Check BIM and split

```
perl HRC-1000G-check-bim.pl -b 20230216_TCGA_WTCCC.bim -f 20230216_TCGA_WTCCC.frq -r PASS.Variants.bravo-dbsnp-all.tab.gz -h
























```


```BASH
sh Run-plink.sh
























```


###     Create vcf files using plink


```BASH
for bed in 20230216_TCGA_WTCCC-updated-chr*.bed ; do
base=${bed%.bed}
plink --bfile ${base} --recode vcf --out ${base}
done
```


```BASH
module load htslib/1.10.2
for vcf in 20230216_TCGA_WTCCC*vcf; do
echo $vcf
bgzip $vcf
done
```



###	Check VCF files



CheckVCF
Use checkVCF to ensure that the VCF files are valid. checkVCF proposes "Action Items" (e.g. upload to sftp server), which can be ignored. Only the validity should be checked with this command.



```BASH
for vcf in 20230216_TCGA_WTCCC*vcf.gz; do
echo $vcf
bgzip $vcf
checkVCF.py -r /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/20180810/hg38.chrXYM_alts.fa.gz -o out $vcf
done
```







##      Upload

Copy the files locally.
```
scp c4:/francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20230215-prep_for_imputation/*vcf.gz ./
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







