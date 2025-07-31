
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20250723-survival_gwas


AGS
Impute and analyse separately
Meta analysis scripts from Geno - survival gwas


plink has issues with underscores in sample names as it uses an underscore to separate FID and IID
Not sure how Geno dealt with this.

After some test runs with --update-ids, simply changing underscores to dashes in the fam file does not change the bim or bed file so just changing the fam files.




```BASH
mkdir hg19-onco
mkdir hg19-i370
mkdir hg19-cidr
mkdir hg19-tcga

ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bed hg19-onco/onco.bed
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bim hg19-onco/onco.bim
sed -e 's/_/-/g' /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.fam > hg19-onco/onco.fam


ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bed hg19-i370/i370.bed
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bim hg19-i370/i370.bim
sed -e 's/_/-/g' /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.fam > hg19-i370/i370.fam


#	CIDR


ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.bed hg19-tcga/tcga.bed
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.bim hg19-tcga/tcga.bim
sed -e 's/_/-/g' /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.fam > hg19-tcga/tcga.fam

```




##	Create a frequency file


```BASH
for b in i370 onco cidr tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_freq --wrap="module load plink; plink --freq --bfile ${PWD}/hg19-${b}/${b} --out ${PWD}/hg19-${b}/${b};chmod -w ${PWD}/hg19-${b}/${b}.frq" --out=${PWD}/hg19-${b}/plink.create_frequency_file.log
done
```






##	Liftover hg19 to hg38

Both picard and bcftools drop A LOT of SNPs.

This built-in liftover from the imputation server utils allows many more to pass. Not sure if this is good or bad.



```BASH
for b in i370 onco cidr tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=16 --mem=120G --export=None --job-name=${b}_plink_liftover --out=${PWD}/plink_liftover_${b}.out ${PWD}/plink_liftover_hg19_to_hg38.bash ${PWD}/hg19-${b}/${b} ${PWD}/hg38-${b}
done
```


















#	#	The HRC reference panel is hg19 so no need to do anything if using that.
#	#	
#	#	
#	#	The TOPMed reference panel to check is hg38 so I'm pretty sure that our data needs to be lifted over to hg38.
#	#	
#	#	I'm not sure what build the 1000genomes reference panel is.
#	#	
#	#	I don't trust lifting over, but here we are.
#	#	
#	#	
#	#	
#	#	Adding the "chr" prefix to the hg19 reference before lifting it over. 
#	#	
#	#	Not sure if needed here, but when uploading to impute it will be.
#	#	
#	#	That's how they test which build it is.
#	#	
#	#	
#	#	Convert bed/bim/fam to hg19 vcf file with chr prefix
#	#	```BASH
#	#	for b in i370 onco cidr tcga ; do
#	#	sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b} --wrap="module load plink2; plink2 --threads 4 --bfile prep-${b}/${b} --output-chr chrM --out prep-${b}/${b}.hg19chr --export vcf bgz; bcftools index --tbi prep-${b}/${b}.hg19.vcf.gz; chmod -w prep-${b}/${b}.hg19.vcf.gz prep-${b}/${b}.hg19.vcf.gz.tbi"
#	#	done
#	#	```
#	#	
#	#	
#	#	Liftover hg19 vcf file to hg38
#	#	
#	#	
#	#	Change hg38.chrXYM_alts.fa.gz to  hg38.chrXYM_no_alts.fa.gz to drop all of the alternate chromosomes which plink doesn't like.
#	#	
#	#	`Error: Invalid chromosome code 'chr7_KI270803v1_alt' on line 299312 of .bim`
#	#	
#	#	Liftover now fails. How can I just ignore these?
#	#	
#	#	`ERROR	2025-07-29 08:16:51	LiftoverVcf	Encountered a contig, chr7_KI270803v1_alt that is not part of the target reference.`
#	#	
#	#	Looks like we may need to keep them and then filter them. Put the "alts" version back
#	#	
#	#	
#	#	```BASH
#	#	for b in i370 onco cidr tcga ; do
#	#	
#	#	sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=32 --mem=240G --export=None --job-name=${b} --out=${PWD}/prep-${b}/picard-liftover.log --wrap="module load picard; java -Xmx220G -jar \$PICARD_HOME/picard.jar LiftoverVcf I=prep-${b}/${b}.hg19chr.vcf.gz O=prep-${b}/${b}.hg38.vcf.gz CHAIN=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz REJECT=prep-${b}/${b}.hg38-rejected.vcf.gz R=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa.gz; chmod -w prep-${b}/${b}.hg38.vcf.gz prep-${b}/${b}.hg38.vcf.gz.tbi"
#	#	
#	#	done
#	#	```
#	#	
#	#	
#	#	filter out alternate chromosomes
#	#	
#	#	```BASH
#	#	for b in i370 onco cidr tcga ; do
#	#	sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b} --out=${PWD}/prep-${b}/filter_out_alternates.log --wrap="bcftools view -r chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22 prep-${b}/${b}.hg38.vcf.gz -Oz --output prep-${b}/${b}.hg38.filtered.vcf.gz; bcftools index --tbi prep-${b}/${b}.hg38.filtered.vcf.gz; chmod -w prep-${b}/${b}.hg38.filtered.vcf.gz prep-${b}/${b}.hg38.filtered.vcf.gz.tbi"
#	#	done
#	#	```
#	#	










##	Check BIM and split


The `HRC-1000G-check-bim.pl` requires that the chromosomes be numeric at this stage regardless of hg19 or hg38.


###	HRC

Not using HRC but running this anyway for comparison.

```BASH
for b in i370 onco cidr tcga ; do
mkdir prep-${b}-HRC
cd prep-${b}-HRC
ln -s ../hg19-${b}/${b}.bed
ln -s ../hg19-${b}/${b}.bim
ln -s ../hg19-${b}/${b}.fam
ln -s ../hg19-${b}/${b}.frq
cd ..
done
```

Standard HRC on original hg19 bed/bim/fam

```BASH
for b in i370 onco cidr tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_check-bim --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --bim ${PWD}/prep-${b}-HRC/${b}.bim --frequency ${PWD}/prep-${b}-HRC/${b}.frq --ref /francislab/data1/refs/Imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab --hrc" --out=${PWD}/prep-${b}-HRC/HRC-1000G-check-bim.pl.log
done
```


###	1000g

Link the original hg19 versions of plink files

```BASH
for b in i370 onco cidr tcga ; do
mkdir prep-${b}-1000g
cd prep-${b}-1000g
ln -s ../hg19-${b}/${b}.bed
ln -s ../hg19-${b}/${b}.bim
ln -s ../hg19-${b}/${b}.fam
ln -s ../hg19-${b}/${b}.frq
cd ..
done
```


Check against a 1000 genomes panel

```BASH
for b in i370 onco cidr tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_check-bim --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --verbose --bim ${PWD}/prep-${b}-1000g/${b}.bim --frequency ${PWD}/prep-${b}-1000g/${b}.frq --ref /francislab/data1/refs/Imputation/1000GP_Phase3_combined.legend --1000g" --out=${PWD}/prep-${b}-1000g/HRC-1000G-check-bim.pl.log
done
```



###	TOPMed

Link hg38 files in prep for checking again TOPMed panel


```BASH
for b in i370 onco cidr tcga ; do
mkdir prep-${b}-TOPMed
cd prep-${b}-TOPMed
ln -s ../hg38-${b}/${b}.bed
ln -s ../hg38-${b}/${b}.bim
ln -s ../hg38-${b}/${b}.fam
ln -s ../hg38-${b}/${b}.frq
cd ..
done
```

Check against TOPMed panel

Dropping to 4/30 as don't think I actually need 8/60

```BASH
for b in i370 onco cidr tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_check-bim --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --verbose --bim ${PWD}/prep-${b}-TOPMed/${b}.bim --frequency ${PWD}/prep-${b}-TOPMed/${b}.frq --ref /francislab/data1/refs/Imputation/PASS.Variants.TOPMed_freeze5_hg38_dbSNP.tab --hrc" --out=${PWD}/prep-${b}-TOPMed/HRC-1000G-check-bim.pl.log
done

```


i370 loses A LOT. Testing a lower frequency threshold. Probably should raise it, but trying --noexclude.

i370 still ends up failing ...

```
Warning: 2 Chunk(s) excluded: < 20 SNPs (see chunks-excluded.txt for details).
Warning: 287 Chunk(s) excluded: reference overlap < 50.0% (see chunks-excluded.txt for details).
Remaining chunk(s): 1
```

For consistency, using the 1000g filtered data on TOPMed. Not sure if this is the best decision.



##	Run the generated scripts



WAIT UNTIL THE PREVIOUS SCRIPT COMPLETE!


Don't need the individual bed/bim/fam filesets so commenting them out.


Standard HRC
1000 genomes

```BASH
for b in i370 onco cidr tcga ; do
for s in HRC 1000g ; do
sed -i -e '/--make-bed --chr/s/^/#/' prep-${b}-${s}/Run-plink.sh
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_run-plink --wrap="module load plink; sh ${PWD}/prep-${b}-${s}/Run-plink.sh;\rm ${PWD}/prep-${b}-${s}/TEMP?.*" --out=${PWD}/prep-${b}-${s}/Run-plink.sh.log
done
done
```

Since this is hg38, NEED to re-add the chr prefix so changing the output chr format.

TOPMed

```BASH
for b in i370 onco cidr tcga ; do
sed -i -e '/--recode vcf --chr/s/--chr/--output-chr chrM --chr/' -e '/--make-bed --chr/s/^/#/' prep-${b}-TOPMed/Run-plink.sh
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_run-plink --wrap="module load plink; sh ${PWD}/prep-${b}-TOPMed/Run-plink.sh;\rm ${PWD}/prep-${b}-TOPMed/TEMP?.*" --out=${PWD}/prep-${b}-TOPMed/Run-plink.sh.log
done
```






##	Compress

```BASH
for b in i370 onco cidr tcga ; do
for s in HRC 1000g TOPMed ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_bgzip --wrap="module load htslib; bgzip ${PWD}/prep-${b}-${s}/*vcf; chmod a-w ${PWD}/prep-${b}-${s}/*{bim,bed,fam,vcf.gz}" --out=${PWD}/prep-${b}-${s}/bgzip.log
done; done
```

That should be good.





i370 lost quite a bit and many of the surviving chunks fail on TOPMed

Exclude is HIGH
Force-Allele1 is LOW
ID is HIGH
Strand Flip is LOW


```BASH
ll prep-*/*updated.bed
-r--r----- 1 gwendt francislab  316234383 Jul 29 19:14 prep-i370-1000g/i370-updated.bed
-r--r----- 1 gwendt francislab  337594953 Jul 29 19:14 prep-i370-HRC/i370-updated.bed
-r--r----- 1 gwendt francislab   12815883 Jul 30 08:05 prep-i370-TOPMed/i370-updated.bed   <----- < 5% of others
-r--r----- 1 gwendt francislab  422324451 Jul 29 19:14 prep-onco-1000g/onco-updated.bed
-r--r----- 1 gwendt francislab  440367567 Jul 29 19:14 prep-onco-HRC/onco-updated.bed
-r--r----- 1 gwendt francislab  424606731 Jul 29 19:14 prep-onco-TOPMed/onco-updated.bed
-r--r----- 1 gwendt francislab 1057654152 Jul 29 19:14 prep-tcga-1000g/tcga-updated.bed
-r--r----- 1 gwendt francislab 1096467595 Jul 29 19:14 prep-tcga-HRC/tcga-updated.bed
-r--r----- 1 gwendt francislab 1079667521 Jul 29 19:15 prep-tcga-TOPMed/tcga-updated.bed
```



















#	#	##	validation check
#	#	
#	#	having issues on umich with many ref panels silently failing
#	#	
#	#	```BASH
#	#	for f in *-updated-*vcf.gz ; do echo $f; tabix $f; done
#	#	```
#	#	
#	#	
#	#	```BASH
#	#	java -Xmx50G -jar /francislab/data1/refs/Imputation/imputationserver-utils.jar \
#	#	 validate \
#	#	 --reference /francislab/data2/refs/Imputation/1kgp3.reference-panel.json \
#	#	 --population off \
#	#	 --phasing eagle \
#	#	 --build hg19 \
#	#	 --mode imputation \
#	#	 --minSamples 20 \
#	#	 --maxSamples 50000 \
#	#	 --report validation_report.txt \
#	#	 --no-index \
#	#	 --contactName jake \
#	#	 --contactEmail jakewendt@gmail.com \
#	#	 prep-i370/*-updated-*vcf.gz
#	#	```
#	#	































##	Impute Genotypes


ALWAYS USE EAGLE. NEVER USE BEAGLE!


Will need UMICH and TOPMED TOKENS

TOPMed apps@topmed-r3



TOPMed checked hg38

```BASH
#impute_genotypes.bash --server topmed --refpanel topmed-r3 --build hg38 --population all -n 20250729-tcga prep-tcga-TOPMed/tcga-updated-chr*.vcf.gz
#impute_genotypes.bash --server topmed --refpanel topmed-r3 --build hg38 --population all -n 20250729-onco prep-onco-TOPMed/onco-updated-chr*.vcf.gz
#impute_genotypes.bash --server topmed --refpanel topmed-r3 --build hg38 --population all -n 20250729-i370 prep-i370-TOPMed/i370-updated-chr*.vcf.gz
#impute_genotypes.bash --server topmed --refpanel topmed-r3 --build hg38 --population all -n 20250801-cidr prep-cidr-TOPMed/cidr-updated-chr*.vcf.gz
```


i370 almost entirely fails. Bad liftover??? Check script removes most. Imputation removes most of what's left.

I'd love to get ahold of a hg19 TOPMed panel to use instead of the hg38


```
impute_genotypes.bash --server topmed --refpanel topmed-r3 --population all -n 20250730-i370-1kg prep-i370-1000g/i370-updated-chr*.vcf.gz
impute_genotypes.bash --server topmed --refpanel topmed-r3 --population all -n 20250729-tcga-1kg prep-tcga-1000g/tcga-updated-chr*.vcf.gz
impute_genotypes.bash --server topmed --refpanel topmed-r3 --population all -n 20250729-onco-1kg prep-onco-1000g/onco-updated-chr*.vcf.gz

```




UMich 1000g checked hg19

Population 'all' is not supported by reference panel '1000g-phase-3-v5'.

```BASH
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 -n 20250729-tcga-1kghg19 prep-tcga-1000g/tcga-updated-chr*.vcf.gz
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 -n 20250729-onco-1kghg19 prep-onco-1000g/onco-updated-chr*.vcf.gz
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 -n 20250729-i370-1kghg19 prep-i370-1000g/i370-updated-chr*.vcf.gz


impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 -p off -n 20250801-cidr-1kghg19  prep-cidr-1000g/cidr-updated-chr*.vcf.gz
```


Impute on UMICH hg38 beta as well apps@1000g-phase3-deep@1.0.0



after liftover ...

Error: More than 100 allele switches have been detected. Imputation cannot be started!

Now they fail silently????



```BASH
impute_genotypes.bash --server umich --refpanel 1000g-phase3-deep -n 20250729-tcga-1kghg38 prep-tcga-1000g/tcga-updated-chr*.vcf.gz - FAILS QC?
impute_genotypes.bash --server umich --refpanel 1000g-phase3-deep -n 20250729-onco-1kghg38 prep-onco-1000g/onco-updated-chr*.vcf.gz - FAILS QC?
impute_genotypes.bash --server umich --refpanel 1000g-phase3-deep -n 20250729-i370-1kghg38 prep-i370-1000g/i370-updated-chr*.vcf.gz - FAILS QC?

impute_genotypes.bash --server umich --refpanel 1000g-phase3-deep -n 20250801-cidr-1kghg38  prep-cidr-1000g/cidr-updated-chr*.vcf.gz
```




##	Download

```BASH
mkdir imputed-topmed-onco
cd imputed-topmed-onco




cd ..


mkdir imputed-topmed-i370
cd imputed-topmed-i370




cd ..


mkdir imputed-topmed-tcga
cd imputed-topmed-tcga




cd ..

mkdir imputed-topmed-cidr
cd imputed-topmed-cidr




cd ..

chmod -w imputed-topmed-*/*
```

```
mkdir imputed-umich19-onco
cd imputed-umich19-onco
curl -sL https://imputationserver.sph.umich.edu/get/GZhNBZDWp822Z0EZTUzPvIbgBCaU9K2zEQyvOYuq | bash
cd ..

mkdir imputed-umich19-i370
cd imputed-umich19-i370
curl -sL https://imputationserver.sph.umich.edu/get/twyYnI3P5v3XZ3WbdNGabELUWFU4mNtiHnBKLrcO | bash
cd ..

mkdir imputed-umich19-tcga
cd imputed-umich19-tcga
curl -sL https://imputationserver.sph.umich.edu/get/OaRAlzXs2TAxbwD1wQcDdpMIDZRWHHj5AuAewlCU | bash
cd ..




mkdir imputed-umich19-cidr
cd imputed-umich19-cidr




cd ..

chmod -w imputed-umich19-*/*
```

```
mkdir imputed-umich38-onco
cd imputed-umich38-onco




cd ..


mkdir imputed-umich38-i370
cd imputed-umich38-i370




cd ..


mkdir imputed-umich38-tcga
cd imputed-umich38-tcga




cd ..

mkdir imputed-umich38-cidr
cd imputed-umich38-cidr




cd ..

chmod -w imputed-umich38-*/*
```


Create and chmod password files for umich and topmed and each dataset

```BASH
for s in topmed umich19 umich38 ; do
for b in onco i370 tcga cidr ; do
  echo ${s}-${b}
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


This is getting really complicated so let's make some decisions.


Prep for imputation as directed and impute on TOPMed


Run GWAS on MY imputed results...
	impute Onco, Il370 and incoming CIDR AGS datasets on TOPMed
	this has nothing to do with the PGSs


Any QC filtering on the resulting imputations?

	Any SNP filtering could be done by chromosome

	Any sample filtering would need to wait until after concatenation


###	QC and Filter




```BASH
#for f in {umich19,umich38,topmed}-*/*dose.vcf.gz ; do
for f in */*dose.vcf.gz ; do
 b=${f%.dose.vcf.gz}
 echo "module load plink2; plink2 --threads 4 --vcf ${f} dosage=DS --maf 0.01 --hwe 1e-5 --geno 0.01 --exclude-if-info 'R2 < 0.8' --out ${b}.QC --export vcf bgz vcf-dosage=DS-force; bcftools index --tbi ${b}.QC.vcf.gz; chmod -w ${b}.QC.vcf.gz ${b}.QC.vcf.gz.tbi"
done >> plink_commands


commands_array_wrapper.bash --array_file plink_commands --time 1-0 --threads 4 --mem 30G


#	or if the cluster's down login to n17 and ...
#	parallel -j 16 < plink_commands



#	X wasn't included in these data
#Error: chrX is present in the input file, but no sex information was provided;
#rerun this import with --psam or --update-sex.  --split-par may also be
#appropriate.
```

--set-all-var-ids chr@:#:\$r:\$a --new-id-max-allele-len 50

may to use vcf-dosage=DS-force to set 0s? Nulls actually. Can mean 0, 1 or 2.





need to create case lists for all datasets and subsets (done for onco and i370?)
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



###	Concat

gonna take about a day


don't include X as not in all datasets?

```BASH
for s in topmed umich19 umich38 ; do
for b in onco i370 tcga cidr ; do

  sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=concat-${s}-${b} \
    --export=None --output="${PWD}/concat-${s}-${b}.$( date "+%Y%m%d%H%M%S%N" ).out" \
    --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
    --wrap="module load bcftools; bcftools concat --output ${s}-${b}/concated.vcf.gz ${s}-${b}/chr[1-9]{,?}.QC.vcf.gz; bcftools index --tbi ${s}-${b}/concated.vcf.gz; chmod -w ${s}-${b}/concated.vcf.gz ${s}-${b}/concated.vcf.gz.tbi"

done; done
```






module load plink; plink --threads 4 --vcf topmed-onco/concated.vcf.gz --out test.concated.QC

plink \
    --bfile EUR \
    --extract EUR.QC.prune.in \
    --keep EUR.QC.fam \
    --het \
    --out EUR.QC












----

STILL NEEDS EDITTING!!!



link the support files to create location and naming consistency


```BASH
ln -s /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_Onco_glioma_cases.txt onco_glioma_cases.txt
ln -s /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_i370_glioma_cases.txt i370_glioma_cases.txt

#	--- CIDR glioma case list
```



FAM files ...
Family ID (FID): A unique identifier for the family the sample belongs to.
Individual ID (IID): A unique identifier for the individual within the family.
Paternal ID: The ID of the individual's father, or "0" if unknown or not in the dataset.
Maternal ID: The ID of the individual's mother, or "0" if unknown or not in the dataset.
Sex: A numerical code indicating the individual's sex (1=Male, 2=Female, 0=Unknown).
Phenotype: A numerical code indicating the sample's phenotype (1=Control, 2=Case, -9 or 0=Missing data).




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

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pull_dosage-i370-test \
  --export=None --output="${PWD}/pull_dosage-i370-test.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=16 --mem=120G \
  pull_case_dosage.bash --IDfile /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_i370_glioma_cases.txt \
  --vcffile /francislab/data1/working/20210302-AGS-illumina/20220425-Pharma/data/AGS_i370_pharma_merged.vcf.gz \
  --outbase ${PWD}/topmed-i370-test3

```



NEED the CIDR case list



If all went well, create our own.

```BASH
for s in topmed umich19 umich38 ; do
for b in onco i370 tcga cidr ; do

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
for s in topmed umich19 umich38 ; do
for b in onco i370 tcga cidr ; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=gwassurvivr-${s}-${b} \
  --export=None --output="${PWD}/gwas-${s}-${b}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G gwasurvivr.bash \
  --dataset ${b} --vcffile ${s}-${b}/${b}_glioma_cases/${b}_glioma_cases.vcf.gz --outbase ${PWD}/gwas-${s}-${b}/

done; done
```


###	spacox.bash



```BASH
for s in topmed umich19 umich38 ; do
for b in onco i370 tcga cidr ; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=gwasspacox-${s}-${b} \
  --export=None --output="${PWD}/gwas-${s}-${b}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G spacox.bash --dataset ${b} \
  --dosage ${s}-${b}/${b}_glioma_cases/${b}_glioma_cases.dosage --outbase ${PWD}/gwas-${s}-${b}/

done; done
```


###	Merge

then merge those results

```BASH
for s in topmed umich19 umich38 ; do
for b in onco i370 tcga cidr ; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=merge-${s}-${b} \
  --export=None --output="${PWD}/merge-${s}-${b}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G \
  merge_gwasurvivr_spacox.bash --dataset ${b} --outbase ${PWD}/gwas-${s}-${b}/

done; done
```






then METAL



impute_genotypes.bash --server umich --refpanel 1000g-phase3-deep -n 20250725-onco-1kghg38  prep-onco/onco-updated-chr*.vcf.gz
impute_genotypes.bash --server umich --refpanel 1000g-phase3-deep -n 20250725-i370-1kghg38 prep-i370/i370-updated-chr*.vcf.gz
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 -n 20250725-onco-1kghg19  prep-onco/onco-updated-chr*.vcf.gz
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 -n 20250725-i370-1kghg19 prep-i370/i370-updated-chr*.vcf.gz

