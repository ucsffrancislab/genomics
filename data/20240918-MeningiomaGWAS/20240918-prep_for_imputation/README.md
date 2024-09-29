
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
mv Chromosome-MENINGIOMA_GWAS_SHARED-HRC.txt Exclude-MENINGIOMA_GWAS_SHARED-HRC.txt Force-Allele1-MENINGIOMA_GWAS_SHARED-HRC.txt FreqPlot-MENINGIOMA_GWAS_SHARED-HRC.txt ID-MENINGIOMA_GWAS_SHARED-HRC.txt LOG-MENINGIOMA_GWAS_SHARED-HRC.txt plink.create_frequency_file.log Position-MENINGIOMA_GWAS_SHARED-HRC.txt Run-plink.sh Run-plink.sh.log Strand-Flip-MENINGIOMA_GWAS_SHARED-HRC.txt prep/
```



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


Quality Control (Report)
Execution successful.


Pre-phasing and Imputation
Chr 11Chr 22Chr 12Chr 13Chr 14Chr 15
Chr 16Chr 17Chr 18Chr 19Chr 1Chr 2
Chr 3Chr 4Chr 5Chr 6Chr 7Chr 8
Chr 9Chr 20Chr 10Chr 21

  Waiting
  Running
  Complete


Data Compression and Encryption
Exported data.

We have sent an email to jakewendt@gmail.com with the password.
```


https://imputation.biodatacatalyst.nhlbi.nih.gov/#!jobs/job-20240919-150354-655/results


Then wait for the process. Started ...
...


I was emailed a password which I put in a file called `password`

```BASH
mkdir imputation
cd imputation

wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/2b2d696d56144293c7a1f7de1bf4c1028cd7f246e9546c38c8a8fe9a2d040f87/qcreport.html

wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/9d6d2ea3e660d646e1d306840de80696aac1d228ccbc34e1e6c7a49088164a66/chunks-excluded.txt
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/5d742169189159936638e2c167ff653d5fb409632253199218a20e3519aff609/snps-excluded.txt
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/2b5a873ecd14fbad9ddd73ab1f199b598d9170172dd0913b02dca2b8ce8e37f0/typed-only.txt

wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/ac55a1eff7b1effd744480cb5c93782ecf9da055e1957fee93d8d69db159049f/chr_1.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/c7a30d511841f497e02be011fa61f2f0415edaed5410c9099f9b94184810aa8f/chr_10.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/17b9780872b510a819b4da2750d12a1f48110c3a44f69a24404398567fb0ad35/chr_11.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/a318a33ab9d4a1b64e5aa63f447d6928eaac7016077d9edc9635c84cce320ef5/chr_12.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/1b195bc070629be7f57a833adb0d6df2918601944223511b984af3cd73aa8d44/chr_13.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/babed5e94b3d2fc324d0d55d9ab2036ed53cee91323edadbfaf9c92e0d864e02/chr_14.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/94e49b9b961fd2243b757b1cdb93411cc9ade94f25e13b9fe65fba741882f4a7/chr_15.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/1d2cefa4821b05af0238d7a002a5fa90223100cf6e1aef3adae843cfe31dc47d/chr_16.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/9f125daf4642a90759b3cc66ca98f9fa4ee1194604857794e6159bee0f96ab54/chr_17.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/544bb4519a919c2c17ccd16b34703c8968d3382cf67e0bfeddef3ccca45b7132/chr_18.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/5ff9cbc1ff5c5d9003124c8ae2070dac27cce7d9e32998a27cfb2f94ed23fe9e/chr_19.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/a85d8b629fe1a82e5c86f954432c828eacb2978faef7df5d2445615b744e54d3/chr_2.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/c11f585180b6648ab1ceab8945b3cd5a85fdc761332c9179e25c06adfeef5361/chr_20.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/ceb35ab8a82c77a08385df51ae88a8b4f7461938e0fa4f70eb1dbf0a8fac53d2/chr_21.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/8b3f8e1ff042570020c1b728c91df57b07cdcb975df2db38aa7804eaed237c01/chr_22.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/c7bcc30f01f01927d07d70a4f8ca6f03ea1d1ff8668b19b4003db6633270d5b0/chr_3.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/797bb7cd9576ac0d01416dffb674247fd39cbdc819f466d7e66b4ae3de028daa/chr_4.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/2a5bd153c1ebcaf5211d57fb8e5722ef53a870f23758cdd37dd50f94691f88e7/chr_5.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/cb59c6555f44dfcfce44753ff85f0e0783308d0434f6c81f5224e3f1729ec655/chr_6.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/6c70925cc34727a319906e111eaa345a66e9992f51fe835ca0fc0dd95fe1621b/chr_7.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/620596dd2ca4c15a0882dabbb5fd58f4d7dd00971aa173700dfe411a1d292ff6/chr_8.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/020665648a9deefdf4d5241b1fd8131029b3f845c3e91196f756c6e6e6e42f37/chr_9.zip
wget https://imputation.biodatacatalyst.nhlbi.nih.gov/share/results/feec668e21bdbaf32120ecf0c3bed1eb3db9374d91720057d1793c1cf87435cb/results.md5


chmod a-w *

for zip in chr*zip ; do
echo $zip
unzip -P $( cat password ) $zip
done
```





##	20240924

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




https://imputationserver.sph.umich.edu/#!jobs/job-20240924-132158-520




Input Validation
```
22 valid VCF file(s) found.
Samples: 4231
Chromosomes: 1 10 11 12 13 14 15 16 17 18 19 2 20 21 22 3 4 5 6 7 8 9
SNPs: 441862
Chunks: 153
Datatype: unphased
Build: hg19
Reference Panel: 1000g-phase-3-v5 (hg19)
Population: off
Phasing: eagle
Mode: imputation
```




Quality Control
```
Skip allele frequency check.

Calculating QC Statistics

Statistics:
Alternative allele frequency > 0.5 sites: 108,112
Reference Overlap: 99.77 %
Match: 439,945
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
Allele mismatch: 898
SNPs call rate < 90%: 0

Excluded sites in total: 898
Remaining sites in total: 439,945
See snps-excluded.txt for details
Typed only sites: 1,019
See typed-only.txt for details
Warning: 1 Chunk(s) excluded: < 3 SNPs (see chunks-excluded.txt for details).
Remaining chunk(s): 152

Quality Control Report
```




```
Phasing and Imputation
Phasing with Eagle (152/152)

Imputation (152/154)   <----- ?


Ancestry Estimation
Prepare Data (1/1)

Prepare Data (85/85)

Estimate Ancestry

Visualize Ancestry


Polygenic Scores
Trait Category: all
Number of Scores: 0

Calculate Polygenic Scores (152/153)   <----- ?

Analyze Polygenic Scores

Merge Polygenic Scores

Create Ploygenic Score Report

Data have been exported successfully. We have sent a notification email to jakewendt@gmail.com
```





```
mkdir pgs; cd pgs
curl -sL https://imputationserver.sph.umich.edu/get/5yGtUUVw7kZGliSzs27T8A7mh6YNAsE6fecqlWLG | bash

```


