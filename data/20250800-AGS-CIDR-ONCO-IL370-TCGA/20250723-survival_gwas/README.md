
#	20250800-AGS-CIDR-ONCO-Illumina-TCGA/20250723-survival_gwas


AGS
Impute and analyse separately
Meta analysis scripts from Geno - survival gwas



```BASH
mkdir prep-onco
mkdir prep-il370
mkdir prep-cidr

ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bed prep-onco/onco.bed
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bim prep-onco/onco.bim
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.fam prep-onco/onco.fam

ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bed prep-il370/il370.bed
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bim prep-il370/il370.bim
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.fam prep-il370/il370.fam


#	CIDR


```




##	Create a frequency file


```BASH
for b in il370 onco ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_freq --wrap="module load plink; plink --freq --bfile ${PWD}/prep-${b}/${b} --out ${PWD}/prep-${b}/${b};chmod -w ${PWD}/prep-${b}/${b}.frq" --out=${PWD}/prep-${b}/plink.create_frequency_file.log
done
```

##	Check BIM and split

```BASH
for b in il370 onco ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_check-bim --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --bim ${PWD}/prep-${b}/${b}.bim --frequency ${PWD}/prep-${b}/${b}.frq --ref /francislab/data1/refs/Imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab --hrc" --out=${PWD}/prep-${b}/HRC-1000G-check-bim.pl.log
done
```

##	Run the generated script

```BASH
for b in il370 onco ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_run-plink --wrap="module load plink; sh ${PWD}/prep-${b}/Run-plink.sh;\rm ${PWD}/prep-${b}/TEMP*" --out=${PWD}/prep-${b}/Run-plink.sh.log
done
```

##	Compress

```BASH
for b in il370 onco ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_bgzip --wrap="module load htslib; bgzip ${PWD}/prep-${b}/*vcf; chmod a-w ${PWD}/prep-${b}/*{bim,bed,fam,vcf.gz}" --out=${PWD}/prep-${b}/bgzip.log
done
```

That should be good.


##	Impute Genotypes


Will need UMICH and TOPMED TOKENS

TOPMed apps@topmed-r3

```BASH
impute_genotypes.bash --server topmed --refpanel topmed-r3 -n 20250724-onco  prep-onco/onco-updated-chr*.vcf.gz
impute_genotypes.bash --server topmed --refpanel topmed-r3 -n 20250724-il370 prep-il370/il370-updated-chr*.vcf.gz

impute_genotypes.bash --server topmed --refpanel topmed-r3 -n 20250725-cidr  prep-cidr/cidr-updated-chr*.vcf.gz

```


Impute on UMICH as well apps@1000g-phase3-deep@1.0.0

```BASH
impute_genotypes.bash --server umich --refpanel 1000g-phase3-deep -n 20250728-onco-1kghg38  prep-onco/onco-updated-chr*.vcf.gz
impute_genotypes.bash --server umich --refpanel 1000g-phase3-deep -n 20250728-il370-1kghg38 prep-il370/il370-updated-chr*.vcf.gz
impute_genotypes.bash --server umich --refpanel 1000g-phase3-deep -n 20250728-cidr-1kghg38  prep-cidr/cidr-updated-chr*.vcf.gz
```


UMich 1000g hg38 BETA ??

```BASH
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 -n 20250728-onco-1kghg19  prep-onco/onco-updated-chr*.vcf.gz
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 -n 20250728-il370-1kghg19 prep-il370/il370-updated-chr*.vcf.gz
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 -n 20250728-cidr-1kghg19  prep-cidr/cidr-updated-chr*.vcf.gz
```





##	Download

```BASH
mkdir topmed-onco
cd topmed-onco




cd ..


mkdir topmed-il370
cd topmed-il370




cd ..


mkdir topmed-cidr
cd topmed-cidr




cd ..

chmod -w topmed-*/*
```

```
mkdir umich-onco
cd umich-onco




cd ..


mkdir umich-il370
cd umich-il370




cd ..


mkdir umich-cidr
cd umich-cidr




cd ..

chmod -w umich-*/*
```


Create and chmod password files for umich and topmed and each dataset

```BASH
for s in topmed umich ; do
for b in onco il370 cidr ; do
  cd ${s}-${b}
  chmod a-w *
  for zip in chr*zip ; do
  echo $zip
  unzip -P $( cat ../password-${s}-${b} ) $zip
  done
  chmod 440 *gz
  cd ..
done ; done
```



##	Survival GWAS



This is getting really complicated so let's make some decisions. Post this on slack when "finished"


Prep for imputation as directed and impute on TOPMed


Run GWAS on MY imputed results...
	impute Onco, Il370 and incoming CIDR AGS datasets on TOPMed
	this has nothing to do with the PGSs


Any QC filtering on the resulting imputations?

	Any SNP filtering could be done by chromosome

	Any sample filtering would need to wait until after concatenation


###	QC and Filter
Try this with a vcf file 

```BASH
for f in {umich,topmed}-*/*dose.vcf.gz ; do
b=${f%.dose.vcf.gz}
echo "module load plink2; plink2 --threads 4 --vcf ${f} dosage=DS --maf 0.005 --hwe 1e-5 --geno 0.01 --exclude-if-info 'R2 < 0.8' --out ${b}.QC --export vcf bgz vcf-dosage=DS-force; bcftools index --tbi ${b}.QC.vcf.gz; chmod -w ${b}.QC.vcf.gz ${b}.QC.vcf.gz.tbi"
done >> plink_commands

commands_array_wrapper.bash --array_file plink_commands --time 1-0 --threads 4 --mem 30G

Error: chrX is present in the input file, but no sex information was provided;
rerun this import with --psam or --update-sex.  --split-par may also be
appropriate.
```

--set-all-var-ids chr@:#:\$r:\$a --new-id-max-allele-len 50

may to use vcf-dosage=DS-force to set 0s? Nulls actually. Can mean 0, 1 or 2.



need to rename samples? Should have done before imputation? will need to match the case list used.

	Onco are all like ..
		"0_WG0238723-DNAE03_AGS54527"
		"0_WG0238723-DNAF01_AGS55488"
		"0_WG0238723-DNAF02_AGS54481"

		Change them to AGS_AGS?

	il370
		mostly AGS_AGS
		also 3390 like ...
			"1873031599_A_1873031599_A"
			"1873031620_A_1873031620_A"
			"1873031691_A_1873031691_A"
		which may be ok of they are controls?

	CIDR
		not sure what these will look like


need to create case lists for all datasets and subsets (done for onco and il370?)
	These are used in the gwasurvivr and spacox scripts.
	Are these "cases" then compared against ALL other samples? Doesn't seem right.
	The Onco lists do match the above naming convention ( 0_WG0238627-DNAA08_AGS40816 )

	AGS_i370_HGG_IDHmut_meta_cases
	AGS_i370_HGG_IDHwt_meta_cases
	AGS_i370_IDHmut_meta_cases
	AGS_i370_IDHwt_meta_cases
	AGS_i370_LrGG_IDHmut_1p19qcodel_meta_cases
	AGS_i370_LrGG_IDHmut_1p19qintact_meta_cases
	AGS_i370_LrGG_IDHmut_meta_cases
	AGS_i370_LrGG_IDHwt_meta_cases
	AGS_Onco_HGG_IDHmut_meta_cases
	AGS_Onco_HGG_IDHwt_meta_cases
	AGS_Onco_IDHmut_meta_cases
	AGS_Onco_IDHwt_meta_cases
	AGS_Onco_LrGG_IDHmut_1p19qcodel_meta_cases
	AGS_Onco_LrGG_IDHmut_1p19qintact_meta_cases
	AGS_Onco_LrGG_IDHmut_meta_cases
	AGS_Onco_LrGG_IDHwt_meta_cases


need to merge imputed dose.vcf.gz files to create vcf
	filter?
	minimum R2? - Geno's file seem to only include R2>0.8


###	Concat

onco is gonna take about a day
il370 is gonna take more

```BASH
for s in topmed umich ; do
for b in onco il370 cidr ; do

  sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=concat-${s}-${b} \
    --export=None --output="${PWD}/concat-${s}-${b}.$( date "+%Y%m%d%H%M%S%N" ).out" \
    --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
    --wrap="module load bcftools; bcftools concat --output ${s}-${b}/concated.vcf.gz ${s}-${b}/chr{?,??}.QC.vcf.gz; bcftools index --tbi ${s}-${b}/concated.vcf.gz; chmod -w ${s}-${b}/concated.vcf.gz ${s}-${b}/concated.vcf.gz.tbi"

done; done
```











----

STILL NEEDS EDITTING!!!



link the support files to create location and naming consistency


```BASH
ln -s /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_Onco_glioma_cases.txt onco_glioma_cases.txt
ln -s /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_i370_glioma_cases.txt il370_glioma_cases.txt

#	--- CIDR glioma case list
```




Make case ID files

/francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_Onco_glioma_cases.txt
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20220425-Pharma/data/AGS_Onco_glioma_cases.dosage
/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20220425-Pharma/data/AGS_Onco_pharma_merged.vcf.gz

/francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_i370_glioma_cases.txt
/francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/data/AGS_i370_glioma_cases.dosage
/francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/data/AGS_i370_pharma_merged.vcf.gz

###	Pull cases and dosage

Create some dosage files to compare to Geno's

```BASH

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pull_dosage-onco-test \
  --export=None --output="${PWD}/pull_dosage-onco-test.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  pull_case_dosage.bash --IDfile /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_Onco_glioma_cases.txt \
  --vcffile /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20220425-Pharma/data/AGS_Onco_pharma_merged.vcf.gz \
  --outbase ${PWD}/topmed-onco-test3

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pull_dosage-il370-test \
  --export=None --output="${PWD}/pull_dosage-il370-test.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  pull_case_dosage.bash --IDfile /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_i370_glioma_cases.txt \
  --vcffile /francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/data/AGS_i370_pharma_merged.vcf.gz \
  --outbase ${PWD}/topmed-il370-test3

```



NEED the CIDR case list



If all went well, create our own.

```BASH
for s in topmed umich ; do
for b in onco il370 cidr ; do

  sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pull_dosage-${s}-${b} \
    --export=None --output="${PWD}/pull_dosage-${s}-${b}.$( date "+%Y%m%d%H%M%S%N" ).out" \
    --time=1-0 --nodes=1 --ntasks=16 --mem=120G pull_case_dosage.bash \
    --IDfile ${PWD}/${b}_glioma_cases.txt \
    --vcffile ${PWD}/${s}-${b}/concated.vcf.gz --outbase ${PWD}/${s}-${b}

done; done
```



----

These scripts will need edited to include CIDR

Also, create subset case lists locally

Make case list dir an option?

gwasurvivr.bash, spacox.bash and merge.....bash all use the same




###	gwasurvivr.bash

```BASH
for s in topmed umich ; do
for b in onco il370 cidr ; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=gwassurvivr-${s}-${b} \
  --export=None --output="${PWD}/gwas-${s}-${b}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G gwasurvivr.bash \
  --dataset ${b} --vcffile ${s}-${b}/${b}_glioma_cases/${b}_glioma_cases.vcf.gz --outbase ${PWD}/gwas/

done; done
```


###	spacox.bash



```BASH
for s in topmed umich ; do
for b in onco il370 cidr ; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=gwasspacox-${s}-${b} \
  --export=None --output="${PWD}/gwas-${s}-${b}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G spacox.bash --dataset ${b} \
  --dosage ${s}-${b}/${b}_glioma_cases/${b}_glioma_cases.dosage --outbase ${PWD}/gwas/

done; done
```





--- 
EDIT


###	Merge

then merge those results

```BASH
for s in topmed umich ; do
for b in onco il370 cidr ; do

merge_gwasurvivr_spacox.bash --dataset il370 --outbase ${PWD}/gwas/

merge_gwasurvivr_spacox.bash --dataset onco  --outbase ${PWD}/gwas/

done; done
```

then METAL


