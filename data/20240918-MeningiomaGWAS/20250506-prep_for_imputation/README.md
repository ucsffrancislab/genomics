
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



```
#for i in {1..22}; do
for i in 20 21 22; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=chr${i} --wrap="module load r pandoc; GWAS.Rmd -i ${PWD}/imputed/chr${i}" --out=${PWD}/imputed/chr${i}.Rmd.log
done

```






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








