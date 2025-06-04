
#	20240918-MeningiomaGWAS/20250506-prep_for_imputation

The names of the meningioma samples include underscores, which is plinks preferred delimited.
By being there, converting back from VCFs to bed files it problematic.
In addition, there is a note in the Case/Control file that one of the samples is labeled incorrect.
The correction itself appears to be incorrect.

```
MEN_1_G09_51388,MEN_1_G09_51388,0,0,2,1,62050,IDno 51288 should be replaced by IDno 62050 in the final dataset.  It is a known error in the original manifest.
```

I think that MEN_1_G09_51388 should be changed to MEN_1_G09_62050
and all underscores should be changed to dashes in the fam file.

Then re-prep and re-impute. Hopefully that will make plink happy.



https://topmedimpute.readthedocs.io/en/latest/

https://imputationserver.readthedocs.io/en/latest/prepare-your-data/


If your input data is GRCh37/hg19 please ensure chromosomes are encoded without prefix (e.g. 20).



```BASH
mkdir prep
cd prep

ln -s /francislab/data1/raw/20240918-MeningiomaGWAS/MENINGIOMA_GWAS_SHARED.bed
ln -s /francislab/data1/raw/20240918-MeningiomaGWAS/MENINGIOMA_GWAS_SHARED.bim
#ln -s /francislab/data1/raw/20240918-MeningiomaGWAS/MENINGIOMA_GWAS_SHARED.fam
sed -e 's/MEN_1_G09_51388/MEN_1_G09_62050/g' -e 's/_/-/g' /francislab/data1/raw/20240918-MeningiomaGWAS/MENINGIOMA_GWAS_SHARED.fam > MENINGIOMA_GWAS_SHARED.fam
```

##	Create a frequency file


```BASH
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=freq --wrap="module load plink; plink --freq --bfile ${PWD}/prep/MENINGIOMA_GWAS_SHARED --out ${PWD}/prep/MENINGIOMA_GWAS_SHARED;chmod -w ${PWD}/prep/MENINGIOMA_GWAS_SHARED.frq" --out=${PWD}/prep/plink.create_frequency_file.log
```


##	Check BIM and split

```BASH
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=check-bim --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --bim ${PWD}/prep/MENINGIOMA_GWAS_SHARED.bim --frequency ${PWD}/prep/MENINGIOMA_GWAS_SHARED.frq --ref /francislab/data1/refs/Imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab --hrc" --out=${PWD}/prep/HRC-1000G-check-bim.pl.log
```

Run the generated script

```BASH
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=run-plink --wrap="module load plink; sh ${PWD}/prep/Run-plink.sh;\rm ${PWD}/prep/TEMP*" --out=${PWD}/prep/Run-plink.sh.log
```


```BASH
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=bgzip --wrap="module load htslib; bgzip ${PWD}/prep/*vcf; chmod a-w ${PWD}/prep/*{bim,bed,fam,vcf.gz}" --out=${PWD}/prep/bgzip.log
```

That should be good.





##	Upload

Copy the files locally.
```BASH
mkdir tmp ; cd tmp
scp c4:/francislab/data1/working/20240918-MeningiomaGWAS/20250506-prep_for_imputation/prep/*vcf.gz ./
```

Then upload to the web app.














##	Impute

https://imputation.biodatacatalyst.nhlbi.nih.gov/



Genotype Imputation (Minimac4) 2.0.0-beta3
This is the new Imputation Server Pipeline using Minimac4. Documentation can be found here.

If your input data is GRCh37/hg19 please ensure chromosomes are encoded without prefix (e.g. 20).
If your input data is GRCh38/hg38 please ensure chromosomes are encoded with prefix 'chr' (e.g. chr20).

There is a limit of three concurrent jobs per person. The TOPMed imputation server is a free resource, and these limits allow us to provide service to a wide audience. We reserve the right to terminate users who violate this policy.      https://topmedimpute.readthedocs.io/en/latest/





Name : 20250506-Meningioma

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


X **Generate Meta-imputation File**


**Submit Job**


Wait for files to upload.  This took me about 15 minutes.


Wait for it to process.



https://imputation.biodatacatalyst.nhlbi.nih.gov/#!jobs/job-20250507-003405-057/results


###Input Validation
```
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

###Quality Control
```
Uploaded data is hg19 and reference is hg38.

Lift Over

Calculating QC Statistics

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

Excluded sites in total: 914
Remaining sites in total: 431,392
See snps-excluded.txt for details
Typed only sites: 9,418
See typed-only.txt for details

Warning: 3 Chunk(s) excluded: < 20 SNPs (see chunks-excluded.txt for details).
Warning: 2 Chunk(s) excluded: reference overlap < 50.0% (see chunks-excluded.txt for details).
Remaining chunk(s): 287
```
###Quality Control (Report)
```
Execution successful.
```


```
mkdir imputed
cd imputed

curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1618990/a9ab73ecb18b5ef1acc895e819af77a874a800ca5725b97d17823e95f2b3853e | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1618994/83ef628566c9ba000edb73818b86b0db3e17390567392e27bc711af94e70e65a | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1618997/36bfbd59273d2b28fc77ede1251dfcfe5f76efad141de75229a70990679571c9 | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1618996/c3cc6a817f52bb2eb8b22037605191f3da1434d049fde55803aa8e8f1243c4c5 | bash
```



---





```
chmod a-w *
for zip in chr*zip ; do
echo $zip
unzip -P $( cat ../password ) $zip
done
chmod 440 *gz
```




Basically run Geno’s GWAS script (QC and association testing) the same as we did for our glioma’s
This is mostly to check that we have it right and find the same things the previous analysis did.

Take the PRS results (from the imputation server) and plot the effect (OR) and the p-value in a volcano plot to see if there standout associations


Not explicitly certain how to do either of those so guessing here ...


However, need to do some filtering of the imputed `chr*.dose.vcf.gz` files.

"Poorly imputed SNPs (information measure <0.8), SNPs with a low MAF (<0.005), and SNPs that deviated from HWE (P < 10−5) were excluded."

Should be able to do this with some plink calls as in https://choishingwan.github.io/PRS-Tutorial/target/


How to include the above restrictions??

```
  --maf [freq]        : Exclude variants with minor allele frequency lower than
                        a threshold (default 0.01).

  --hwe <p> ['midp'] ['include-nonctrl'] : Exclude variants with Hardy-Weinberg
                                           equilibrium exact test p-values
                                           below a threshold.

  --geno [val]     : Exclude variants with missing call frequencies greater
                     than a threshold (default 0.1).  (Note that the default
                     threshold is only applied if --geno is invoked without a
                     parameter; when --geno is not invoked, no per-variant
                     missing call frequency ceiling is enforced at all.  Other
                     inclusion/exclusion default thresholds work the same way.)

  --mind [val]     : Exclude samples with missing call frequencies greater than
                     a threshold (default 0.1).

  --write-snplist
  --list-23-indels
    --write-snplist writes a .snplist file listing the names of all variants
    which pass the filters and inclusion thresholds you've specified, while
    --list-23-indels writes the subset with 23andMe-style indel calls (D/I
    allele codes).

  --make-just-fam
    Variants of --make-bed which only write a new .bim or .fam file.  Can be
    used with only .bim/.fam input.
    USE THESE CAUTIOUSLY.  It is very easy to desynchronize your binary
    genotype data and your .bim/.fam indexes if you use these commands
    improperly.  If you have any doubt, stick with --make-bed.

  --indep-pairwise <window size>['kb'] <step size (variant ct)> <r^2 threshold>
  --indep-pairphase <window size>['kb'] <step size (variant ct)> <r^2 thresh>
    Generate a list of markers in approximate linkage equilibrium.  With the
    'kb' modifier, the window size is in kilobase instead of variant count
    units.  (Pre-'kb' space is optional, i.e. "--indep-pairwise 500 kb 5 0.5"
    and "--indep-pairwise 500kb 5 0.5" have the same effect.)
    Note that you need to rerun PLINK using --extract or --exclude on the
    .prune.in/.prune.out file to apply the list to another computation.

  --het ['small-sample'] ['gz']
  --ibc
    Estimate inbreeding coefficients.  --het reports method-of-moments
    estimates, while --ibc calculates all three values described in Yang J, Lee
    SH, Goddard ME and Visscher PM (2011) GCTA: A Tool for Genome-wide Complex
    Trait Analysis.  (That paper also describes the relationship matrix
    computation we reimplement.)
    * These functions require decent MAF estimates.  If there are very few
      samples in your immediate fileset, --read-freq is practically mandatory
      since imputed MAFs are wildly inaccurate in that case.
    * They also assume the marker set is in approximate linkage equilibrium.
    * By default, --het omits the n/(n-1) multiplier in Nei's expected
      homozygosity formula.  The 'small-sample' modifier causes it to be
      included, while forcing --het to use MAFs imputed from founders in the
      immediate dataset.
```

information measure the same as R2?

##INFO=<ID=R2,Number=1,Type=Float,Description="Estimated Imputation Accuracy (R-square)">


```
for i in {1..22}; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=chr${i} --wrap="module load r pandoc; GWAS.Rmd -i ${PWD}/imputed/chr${i}" --out=${PWD}/imputed/chr${i}.Rmd.log
done

```





##	20250516







ARE IMPUTED SNPS THE ORIGINAL REFERENCE HG19 OR ARE THEY THE LIFTED OVER REFERENCE HG38????

The returned chromosomes include "chr" so I think they are hg38

And rs4940595 is in a different position, as an example

```
zgrep rs4940595 prep/MENINGIOMA_GWAS_SHARED-updated-chr18.vcf.gz | cut -c1-90
18	61379838	rs4940595_r	T	G	.	.	.	GT	0/1	0/0	0/1	0/0	0/0	0/0	0/0	0/1	1/1	0/1	0/0	0/0	0/1	0

zgrep rs4940595 imputed/chr18.info.gz 
chr18	63712604	rs4940595	G	T	.	.	IMPUTED;AF=0.711337;MAF=0.288663;AVG_CS=0.993549;R2=0.970421
```







Prep these QC'd data for the PRS imputation server


This is a bit tricky unless I re-concat the individual chromosomes into 1

```BASH
mkdir prep_for_PRS
seq 1 22 | xargs -I _num echo imputed/chr_num.QC > prep_for_PRS/merge_list.txt
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=8 --mem=60G --export=None --job-name=merge --wrap="module load pandoc plink; plink --merge-list ${PWD}/prep_for_PRS/merge_list.txt --make-bed --out ${PWD}/prep_for_PRS/merged; chmod -w ${PWD}/prep_for_PRS/merged.{bed,bim,fam}" --out=${PWD}/prep_for_PRS/merge.log
```



Testing
```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=16 --mem=120G --export=None --job-name=merged --wrap="module load r pandoc; GWAS.Rmd -i ${PWD}/prep_for_PRS/merged-updated-chr22.vcf.gz -o ${PWD}/merged/merged-updated-chr22_vcf -f ${PWD}/imputed/chr22.fam" --out=${PWD}/merged/merged-updated-chr22_vcf.Rmd.log

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=16 --mem=120G --export=None --job-name=merged --wrap="module load r pandoc; GWAS.Rmd -i ${PWD}/prep_for_PRS/merged-updated-chr22 -o ${PWD}/merged/merged-updated-chr22_bbf" --out=${PWD}/merged/merged-updated-chr22_bbf.Rmd.log




sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=16 --mem=120G --export=None --job-name=merged --wrap="module load r pandoc; GWAS.Rmd -i ${PWD}/prep_for_PRS/merged -o ${PWD}/merged/merged" --out=${PWD}/merged/merged.Rmd.log
```





##	Create a frequency file


```BASH
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=freq --wrap="module load plink; plink --freq --bfile ${PWD}/prep_for_PRS/merged --out ${PWD}/prep_for_PRS/merged;chmod -w ${PWD}/prep_for_PRS/merged.frq" --out=${PWD}/prep_for_PRS/plink.create_frequency_file.log
```






##	Check BIM and split

THIS IS SPECIFIC TO HG19

```BASH
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=check-bim --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --bim ${PWD}/prep_for_PRS/merged.bim --frequency ${PWD}/prep_for_PRS/merged.frq --ref /francislab/data1/refs/Imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab --hrc" --out=${PWD}/prep_for_PRS/HRC-1000G-check-bim.pl.log
```

Run the generated script

```BASH
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=run-plink --wrap="module load plink; sh ${PWD}/prep_for_PRS/Run-plink.sh;\rm ${PWD}/prep_for_PRS/TEMP*" --out=${PWD}/prep_for_PRS/Run-plink.sh.log
```


```BASH
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=bgzip --wrap="module load htslib; bgzip ${PWD}/prep_for_PRS/*vcf; chmod a-w ${PWD}/prep_for_PRS/*{bim,bed,fam,vcf.gz}" --out=${PWD}/prep_for_PRS/bgzip.log
```

That should be good.





##	Upload

Copy the files locally.
```BASH
mkdir tmp ; cd tmp
scp c4:/francislab/data1/working/20240918-MeningiomaGWAS/20250506-prep_for_imputation/prep_for_PRS/*vcf.gz ./
```

Then upload to the web app.







##	20250521


This is imputed and QC'd data. Is it still hg19?

Somewhere I've dropped the "chr"?

Comes back as hg38, then the prep scripts convert it back to hg19?

```
grep rs4940595 prep_for_PRS/merged.bim
18	rs4940595	0	63712604	G	T

zgrep rs4940595 prep_for_PRS/merged-updated-chr18.vcf.gz | cut -c1-100
18	61379838	rs4940595	T	G	.	.	.	GT	0/1	0/0	0/1	0/0	0/0	0/0	0/0	0/1	1/1	0/1	0/0	0/0	0/1	0/0	./.	0/0	0
```


Which ref? Try both?


https://imputationserver.sph.umich.edu/#!run/imputationserver2-pgs


Reference Panel
* 1000G Phase 1 v3 Shapeit2 (no singletons) (GRCh37/hg19)
* 1000G Phase 3 (GRCh38/hg38) pBETA]
* 1000G Phase 3 30x (GRCh38/hg38) [BETA}
* **1000G Phase 3 v5 (GRCh37/hg19)**    <----- previous run
* CAAPA African American Panel (GRCh37/hg19)
* Genome Asia Pilot - GAsP (GRCh37/hg19)
* **HRC r1.1 2016 (GRCh37/hg19)**
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


**Submit Job**


Wait for files to upload.  This took me about 15 minutes.


Wait for it to process.


FAILED


```
curl -sL https://imputationserver.sph.umich.edu/get/U9feder5qWdsKPZ3oYH5wOrowRFJVXwTGOHAzEHA | bash
```




##	20250521

```

./genome_check.bash




grep -m1 rs4940595 prep/MENINGIOMA_GWAS_SHARED.bim
18	rs4940595_r	0	61379838	G	T

grep -m1 rs4940595 prep/MENINGIOMA_GWAS_SHARED-updated.bim
18	rs4940595_r	0	61379838	G	T

grep -m1 rs4940595 prep/MENINGIOMA_GWAS_SHARED-updated-chr18.bim
18	rs4940595_r	0	61379838	G	T

zgrep -m1 rs4940595 prep/MENINGIOMA_GWAS_SHARED-updated-chr18.vcf.gz | cut -c1-50
18	61379838	rs4940595_r	T	G	.	.	.	GT	0/1	0/0	0/1	0


zgrep -m1 rs4940595 imputed/chr18.info.gz | cut -c1-100
chr18	63712604	rs4940595	G	T	.	.	IMPUTED;AF=0.711337;MAF=0.288663;AVG_CS=0.993549;R2=0.970421

grep -m1 rs4940595 imputed/chr18.QC.bim
18	rs4940595	0	63712604	G	T

grep -m1 rs4940595 prep_for_PRS/merged.bim
18	rs4940595	0	63712604	G	T



grep -m1 rs4940595 prep_for_PRS/merged-updated.bim
18	rs4940595	0	61379838	G	T

grep -m1 rs4940595 prep_for_PRS/merged-updated-chr18.bim
18	rs4940595	0	61379838	G	T

zgrep -m1 rs4940595 prep_for_PRS/merged-updated-chr18.vcf.gz | cut -c1-50
18	61379838	rs4940595	T	G	.	.	.	GT	0/1	0/0	0/1	0/0

rs4940595:
This rsID has a T as the reference allele and G as the alternative in hg19, causing a stop lost. However, in hg38, the reference is G and the alternative is T, which can cause a stop gained, according to a SEQanswers forum discussion. 
rs855581:
Genotypes for this rsID may appear as both homozygous and heterozygous in hg19, while all individuals appear homozygous in hg38, as mentioned in the SEQanswers discussion. 
```



##	20250522


```
module load plink htslib
mkdir prep_for_PRS

for bed in imputed/*QC.bed ; do
bfile=${bed%.bed}
out=$( basename ${bed} .QC.bed )
plink --bfile ${bfile} --real-ref-alleles --recode vcf --out prep_for_PRS/${out}
sed -i 's/^\([[:digit:]]\)/chr\1/' prep_for_PRS/${out}.vcf
done

bgzip prep_for_PRS/*vcf
```


`If your input data is GRCh37/hg19 please ensure chromosomes are encoded without prefix (e.g. 20).`

So the imputed data is hg38, but does not have chr prefixes. Will it work without them or do I need to add them?



The provided VCF file is malformed.
Error: [tabix] the compression of 'chr22.vcf.gz' is not BGZF



Your upload data contains chromosome '22'. This is not a valid hg38 encoding. Please ensure that your input data is build hg38 and chromosome is encoded as 'chr22'.





Running QC by chromosome separately, has caused each to have differing sets of samples/subjects. I suspect that running PRS on the results may go a bit wonky. We shall see..




I think that I need to
* prep for genotype imputation
* upload and impute online
* download hg38 imputation
* MERGE all chromosomes
* QC merged data
* Either 
  * liftover from hg38 to hg19
    * - or -
  * add chr prefix
* upload and calculate PRS



Concat
```
mkdir -p ${PWD}/imputed_concat
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name=concat --wrap="module load htslib bcftools; bcftools concat --threads 64 -Oz -o ${PWD}/imputed_concat/complete.vcf.gz ${PWD}/imputed/chr?.dose.vcf.gz ${PWD}/imputed/chr??.dose.vcf.gz; chmod -w ${PWD}/imputed_concat/complete.vcf.gz; bcftools index --threads 64 ${PWD}/imputed_concat/complete.vcf.gz" --out=${PWD}/imputed_concat/concat.log 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name=index --wrap="module load htslib bcftools; bcftools index --threads 64 ${PWD}/imputed_concat/complete.vcf.gz; chmod -x ${PWD}/imputed_concat/complete.vcf.gz.csi" --out=${PWD}/imputed_concat/index.log 
```


Run GWAS QC on this single vcf
```
mkdir -p ${PWD}/imputed_QC
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=64 --mem=490G --export=None --job-name=GWAS --wrap="module load r pandoc; GWAS.Rmd -i ${PWD}/imputed_concat/complete.vcf.gz -o ${PWD}/imputed_QC/complete -f ${PWD}/prep/MENINGIOMA_GWAS_SHARED.fam" --out=${PWD}/imputed_QC/complete_GWAS.log

```


That took about 3-4 days.




##	20250528


Convert chromosome names to hg38 style

```
module load plink htslib
mkdir prep_for_PRS

for chr in {1..22} ; do
echo $chr
plink --bfile imputed_QC/complete.QC --real-ref-alleles --recode vcf --chr ${chr} --out prep_for_PRS/chr${chr}
sed -i 's/^\([[:digit:]]\)/chr\1/' prep_for_PRS/chr${chr}.vcf
done

bgzip prep_for_PRS/*vcf
```



Upload locally
Then upload to imputation server
Then wait
Again

Failed. No Error!!!!!!






##	20250530

Try lifting over back to hg19.

Getting sick of the inconsistancy

imputation of hg19 require numeric input, produces hg38 numeric
imputation of hg38 require chr input, produces ???
liftover requires chr input

```
  --output-chr <MT code> : Set chromosome coding scheme in output files by
                           providing the desired human mitochondrial code.
                           (Options are '26', 'M', 'MT', '0M', 'chr26', 'chrM',
                           and 'chrMT'.)
```


```
module load plink htslib gatk
mkdir prep_for_PRS.hg19

plink -bfile imputed_QC/complete.QC --real-ref-alleles --recode vcf bgz --output-chr chr26 --out prep_for_PRS.hg19/complete.QC



gatk LiftoverVcf --CHAIN /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/liftOver/hg38ToHg19.over.chain.gz --INPUT prep_for_PRS.hg19/complete.QC.vcf.gz --OUTPUT prep_for_PRS.hg19/complete.QC.hg19.vcf.gz --REJECT prep_for_PRS.hg19/complete.QC.hg19.reject.vcf.gz --REFERENCE_SEQUENCE /francislab/data1/refs/sources/gencodegenes.org/release_48/GRCh37.primary_assembly.genome.fa.gz

gatk LiftoverVcf --CHAIN /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/liftOver/hg38ToHg19.over.chain.gz --INPUT prep_for_PRS.hg19/complete.QC.vcf.gz --OUTPUT prep_for_PRS.hg19/complete.QC.hg19.vcf.gz --REJECT prep_for_PRS.hg19/complete.QC.hg19.reject.vcf.gz --REFERENCE_SEQUENCE /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.fa.gz




All rejected?



module load WitteLab liftOver

liftOver prep_for_PRS.hg19/complete.QC.ped /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/liftOver/hg38ToHg19.over.chain.gz prep_for_PRS.hg19/complete.QC prep_for_PRS.hg19/complete.QC.unmapped

All unmapped?


trying bcftools +liftover

bcftools +liftover --no-version -o lifttest.hg19.vcf.gz -Oz prep_for_PRS.hg19/complete.QC.vcf.gz -- \
  -s /francislab/data1/refs/sources/gencodegenes.org/release_48/GRCh38.primary_assembly.genome.fa.gz \
  -f /francislab/data1/refs/sources/gencodegenes.org/release_48/GRCh37.primary_assembly.genome.fa.gz \
  -c /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/liftOver/hg38ToHg19.over.chain.gz

bcftools +liftover --no-version -o lifttest.hg19.vcf.gz -Oz prep_for_PRS.hg19/complete.QC.vcf.gz -- \
  -s /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz \
  -f /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.fa.gz \
  -c /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/liftOver/hg38ToHg19.over.chain.gz


Nothing works. Lots of warning about differing lengths. 
Failure on first different reference allele




for chr in {1..22} ; do
echo $chr
plink --vcf prep_for_PRS.hg19/complete.QC.hg19.vcf --real-ref-alleles --recode vcf --output-chr 26 --chr ${chr} --out prep_for_PRS.hg19/chr${chr}
done




```










---

```
plink2 \
	--pfile ${PWD}/imputation/chr22.dose.vcf.gz \
	--keep $scratchpath/AGS_illumina_EUR_ids.txt \
	--pheno iid-only $scratchpath/AGS_illumina_GWAS.phen \
	--pheno-name idhmut_only_gwas,tripneg_gwas,idhwt_1p19qnoncodel_gwas \
	--1 \
	--covar iid-only $scratchpath/AGS_illumina_covariates.txt \
	--covar-name Age,sex,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10 \
	--covar-variance-standardize \
	--glm firth-fallback hide-covar cols=chrom,pos,ref,alt1,a1freq,firth,test,nobs,beta,orbeta,se,ci,tz,p,err \
	--maf 0.01 \
	--memory 15000 \
	--threads 8 \
	--out ${PWD}/testing
```

Then run a modified plink2 command like that in `Geno/GWAS/GWAS-glioma-script.sh`

Then someone merge the resulting GWAS file (vcf?) with the ginormous `pgs/scores.txt`?

That should create some list of SNPs with a beta and p-value?

