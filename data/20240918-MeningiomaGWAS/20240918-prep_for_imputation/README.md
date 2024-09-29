
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






```BASH
module load htslib/1.10.2

for vcf in *vcf; do
echo $vcf
bgzip $vcf
done

chmod a-w *{bim,bed,fam,vcf.gz}
```

That should be good.





##	Upload

Copy the files locally.
```
scp c4:/francislab/data1/working/20240918-MeningiomaGWAS/20240918-prep_for_imputation/*vcf.gz ./
```

Then upload to the web app.






##	Impute

https://imputation.biodatacatalyst.nhlbi.nih.gov/



Genotype Imputation (Minimac4) 2.0.0-beta3
This is the new Imputation Server Pipeline using Minimac4. Documentation can be found here.

If your input data is GRCh37/hg19 please ensure chromosomes are encoded without prefix (e.g. 20).
If your input data is GRCh38/hg38 please ensure chromosomes are encoded with prefix 'chr' (e.g. chr20).

There is a limit of three concurrent jobs per person. The TOPMed imputation server is a free resource, and these limits allow us to provide service to a wide audience. We reserve the right to terminate users who violate this policy.      https://topmedimpute.readthedocs.io/en/latest/





Name : 20240918-MeningiomaGWAS

Reference Panel : 
* **TOPMed r3** (only option)  (NOT r2 like previous runs)

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
* **Eagle v2.4 (phased output)** ( previously I has this ... as **Eagle v2.4 (unphased input)** ?)
* No phasing ( previously I had this as ... * No phasing (phased input) ?)


Population (New option)
* TOPMed r3
* * **vs TOPMed panel**
* * Skip


Mode
* **Quality Control & Imputation**
* Quality Control & Phasing
* Quality Control Only



QC Frequency Check :  (Removed option)
* **vs TOPMed Panel**
* Skip



X **Generate Meta-imputation File**


**Submit Job**


Wait for files to upload.  This took me about 15 minutes.


```
Input Validation
22 valid VCF file(s) found.

Samples: 4231
Chromosomes: 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9
SNPs: 441862
Chunks: 291
Datatype: unphased
Build: hg19
Reference Panel: apps@topmed-r3@1.0.0 (hg38)
Population: all
Phasing: eagle
Mode: imputation
Rsq filter: 0.1

```

Quality Control

```
Uploaded data is hg19 and reference is hg38.

Lift Over [17/22]

Analyze file MENINGIOMA_GWAS_SHARED-updated-chr4.vcf.gz...


```

Quality Control
```
Uploaded data is hg19 and reference is hg38.
```

```
Lift Over
```

```
Calculating QC Statistics
```

```
Statistics:
Alternative allele frequency > 0.5 sites: 108,047
Reference Overlap: 97.87 %
Match: 431,388
Allele switch: 780
Strand flip: 0
Strand flip and allele switch: 0
A/T, C/G genotypes: 4
Filtered sites:
Filter flag set: 0
Invalid alleles: 0
Multiallelic sites: 0
Duplicated sites: 0
NonSNP sites: 0
Monomorphic sites: 0
Allele mismatch: 134
SNPs call rate < 90%: 0
```

```
Excluded sites in total: 914
Remaining sites in total: 431,392
See snps-excluded.txt for details
Typed only sites: 9,418
See typed-only.txt for details

Warning: 3 Chunk(s) excluded: < 20 SNPs (see chunks-excluded.txt for details).
Warning: 2 Chunk(s) excluded: reference overlap < 50.0% (see chunks-excluded.txt for details).
Remaining chunk(s): 287
```


Quality Control (Report)
```
Running Command...

Execution successful.

```



https://imputation.biodatacatalyst.nhlbi.nih.gov/#!jobs/job-20240919-150354-655/results


---





Then wait for the process. Started ...
...


I was emailed a password which I put in a file called `password`

```BASH
mkdir imputation
cd imputation


wget https://imputation.biodatacatalyst.nhlbi.nih.gov/get/252522/085409efc0892e98d3fcc413e994e7a07c2733c44cd78135338878b2c3c00ef8
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/get/252526/1b9458a179ac90808e6f9c22ee92a7e3729cb841c7eabdd98cee4cac123468a9
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/get/252528/3aaab82245adcdd73eb57f697ba6a5e8dded3c9885d6bcfec33960cccf67d392
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/get/252529/f42ccda4a2eba4f60d3f1c102c63dbec4c28ab6415ba1a14c24e9ecf9581fea8


curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/252522/085409efc0892e98d3fcc413e994e7a07c2733c44cd78135338878b2c3c00ef8 | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/252526/1b9458a179ac90808e6f9c22ee92a7e3729cb841c7eabdd98cee4cac123468a9 | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/252528/3aaab82245adcdd73eb57f697ba6a5e8dded3c9885d6bcfec33960cccf67d392 | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/252529/f42ccda4a2eba4f60d3f1c102c63dbec4c28ab6415ba1a14c24e9ecf9581fea8 | bash

chmod a-w *

for zip in chr*zip ; do
echo $zip
unzip -P $( cat password ) $zip
done
```


