
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas

This is a select rerun of 20250723-survival_gwas. Just hg19 on UMich


##	Prepare


I370, Onco, and TCGA are hg19. CIDR is hg38.

I adjusted I370's positions by +1.


```BASH
mkdir hg19-onco
mkdir hg19-i370
mkdir hg19-tcga

ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bed hg19-onco/onco.bed
ln -s /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.bim hg19-onco/onco.bim
sed -e 's/_/-/g' /francislab/data1/raw/20210226-AGS-Mayo-Oncoarray/AGS_Mayo_Oncoarray_for_QC.fam > hg19-onco/onco.fam


ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bed hg19-i370/i370.bed
ln -s /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.bim hg19-i370/i370.bim
sed -e 's/_/-/g' /francislab/data1/raw/20210302-AGS-illumina/AGS_illumina_for_QC.fam > hg19-i370/i370.fam


ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.bed hg19-tcga/tcga.bed
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.bim hg19-tcga/tcga.bim
sed -e 's/_/-/g' /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.fam > hg19-tcga/tcga.fam


mkdir hg38-cidr

ln -s /francislab/data1/raw/20250813-CIDR/CIDR.bed hg38-cidr/cidr.bed
ln -s /francislab/data1/raw/20250813-CIDR/CIDR.bim hg38-cidr/cidr.bim
sed -e 's/_/-/g' /francislab/data1/raw/20250813-CIDR/CIDR.fam > hg38-cidr/cidr.fam

```


###	Create a frequency file


```BASH
for b in i370 onco tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=${b}_freq \
 --wrap="module load plink; plink --freq --bfile ${PWD}/hg19-${b}/${b} --out ${PWD}/hg19-${b}/${b}; \
  chmod -w ${PWD}/hg19-${b}/${b}.frq" \
 --out=${PWD}/hg19-${b}/plink.create_frequency_file.log
done

b=cidr
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=${b}_freq \
 --wrap="module load plink; plink --freq --bfile ${PWD}/hg38-${b}/${b} --out ${PWD}/hg38-${b}/${b}; \
  chmod -w ${PWD}/hg38-${b}/${b}.frq" \
 --out=${PWD}/hg38-${b}/plink.create_frequency_file.log
```






###	Liftover CIDR hg38 to hg19


```BASH

#bcftools +liftover prep-${b}/${b}.hg19chr.vcf.gz -Oz --output prep-${b}/${b}.hg38.vcf.gz -W=tbi -- \
# --src-fasta-ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/latest/hg19.fa.gz \
# --chain /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz \
# --fasta-ref /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz \
# --reject prep-${b}/${b}.hg38.rejected.vcf.gz

```


```BASH

#module load picard; java -Xmx220G -jar \$PICARD_HOME/picard.jar LiftoverVcf I=prep-${b}/${b}.hg19chr.vcf.gz \
# O=prep-${b}/${b}.hg38.vcf.gz \
# CHAIN=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz \
# REJECT=prep-${b}/${b}.hg38-rejected.vcf.gz \
# R=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts.fa.gz

```



This built-in liftover from the imputation server utils allows many more to pass. Not sure if this is good or bad.
Takes about 5 minutes.

```BASH

b=cidr
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=16 --mem=120G --export=None \
 --job-name=${b}_plink_liftover --out=${PWD}/plink_liftover_${b}.out \
 ${PWD}/plink_liftover_hg38_to_hg19.bash ${PWD}/hg38-${b}/${b} ${PWD}/hg19-${b}

```




```BASH
wc -l hg??-*/*bim

  1824987 hg19-cidr/cidr.bim
   293698 hg19-i370/i370.bim
   403388 hg19-onco/onco.bim
   733799 hg19-tcga/tcga.bim
  1904599 hg38-cidr/cidr.bim

```

The CIDR data has many more SNPs than the other datasets.






###	Check BIM and split


The `HRC-1000G-check-bim.pl` requires that the chromosomes be numeric at this stage regardless of hg19 or hg38.


####	1000g

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


Check hg19 against the 1000 genomes panel

```BASH
for b in i370 onco cidr tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=${b}_check-bim \
 --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --verbose \
 --bim ${PWD}/prep-${b}-1000g/${b}.bim --frequency ${PWD}/prep-${b}-1000g/${b}.frq \
 --ref /francislab/data1/refs/Imputation/1000GP_Phase3_combined.legend --1000g" \
 --out=${PWD}/prep-${b}-1000g/HRC-1000G-check-bim.pl.log
done
```



###	Run the generated scripts



WAIT UNTIL THE PREVIOUS SCRIPT COMPLETE!


Don't need the individual bed/bim/fam filesets so commenting them out of the `Run-plink.sh` commands.


```BASH
for b in i370 onco cidr tcga ; do
for s in 1000g ; do
sed -i -e '/--make-bed --chr/s/^/#/' prep-${b}-${s}/Run-plink.sh
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=${b}_run-plink \
 --wrap="module load plink; sh ${PWD}/prep-${b}-${s}/Run-plink.sh;\rm ${PWD}/prep-${b}-${s}/TEMP?.*" \
 --out=${PWD}/prep-${b}-${s}/Run-plink.sh.log
done
done
```




###	Compress

```BASH

for b in i370 onco cidr tcga ; do
for s in 1000g ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=${b}_bgzip \
 --wrap="module load htslib; bgzip ${PWD}/prep-${b}-${s}/*vcf; chmod a-w ${PWD}/prep-${b}-${s}/*{bim,bed,fam,vcf.gz}" \
 --out=${PWD}/prep-${b}-${s}/bgzip.log
done; done

```

That should be good.







```BASH
ll prep-*/*updated.bed
-rw-r----- 1 gwendt francislab  132225657 Dec 18 16:06 prep-cidr-1000g/cidr-updated.bed
-rw-r----- 1 gwendt francislab  316226298 Dec 18 16:06 prep-i370-1000g/i370-updated.bed
-rw-r----- 1 gwendt francislab  422324451 Dec 18 16:06 prep-onco-1000g/onco-updated.bed
-rw-r----- 1 gwendt francislab 1057654152 Dec 18 16:06 prep-tcga-1000g/tcga-updated.bed


wc -l prep-*/*bim
  1824987 prep-cidr-1000g/cidr.bim
  1092774 prep-cidr-1000g/cidr-updated.bim
   293698 prep-i370-1000g/i370.bim
   273789 prep-i370-1000g/i370-updated.bim
   403388 prep-onco-1000g/onco.bim
   386744 prep-onco-1000g/onco-updated.bim
   733799 prep-tcga-1000g/tcga.bim
   629931 prep-tcga-1000g/tcga-updated.bim
```

##	Impute Genotypes


ALWAYS USE EAGLE. NEVER USE BEAGLE!


Will need to create a UMICH TOKEN from your account. Put it in the file called UMICH_TOKEN


```bash

vi UMICH_TOKEN
chmod 400 UMICH_TOKEN

```





UMich 1000g checked hg19

Population 'all' is not supported by reference panel '1000g-phase-3-v5'.

UMich only allows 2 jobs in the queue at a time.

-F "job-name=20251218-tcga-1kghg19" -F "refpanel=1000g-phase-3-v5" -F "build=hg19" -F "r2Filter=0.3" -F "phasing=eagle" -F "population=off"


```BASH
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 --build hg19 \
 -n 20251218-tcga-1kghg19 prep-tcga-1000g/tcga-updated-chr*.vcf.gz | sh
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 --build hg19 \
 -n 20251218-onco-1kghg19 prep-onco-1000g/onco-updated-chr*.vcf.gz | sh
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 --build hg19 \
 -n 20251218-i370-1kghg19 prep-i370-1000g/i370-updated-chr*.vcf.gz | sh
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 --build hg19 \
 -n 20251218-cidr-1kghg19 prep-cidr-1000g/cidr-updated-chr*.vcf.gz | sh
```




##	Download


```
mkdir imputed-umich-onco
cd imputed-umich-onco
curl -sL https://imputationserver.sph.umich.edu/get/VwkIsecWepH98QNnCnWPm9JSUuJJYg8fbd5AoHam | bash
chmod -w *
cd ..

mkdir imputed-umich-i370
cd imputed-umich-i370
curl -sL https://imputationserver.sph.umich.edu/get/pj1iTq92zHRetrWwBULi4YOOsoaolvEADJSakp5W | bash
chmod -w *
cd ..

mkdir imputed-umich-tcga
cd imputed-umich-tcga
curl -sL https://imputationserver.sph.umich.edu/get/tKMtDc5mwDl1Sg7PpI2VGraM0Yd5jZvzAgnb3UgQ | bash
chmod -w *
cd ..

mkdir imputed-umich-cidr
cd imputed-umich-cidr
curl -sL https://imputationserver.sph.umich.edu/get/48PihKmEZAjy8HgYiWvjTwqWWigzuzAr75UzMTHi | bash
chmod -w *
cd ..
```





Create and chmod password files for umich and each dataset

```BASH
for s in umich ; do
for b in onco i370 tcga cidr ; do
  echo ${s}-${b}
  cd imputed-${s}-${b}
  chmod a-w *
  for zip in chr*zip ; do
    echo $zip
    unzip -P $( cat ../password-${s}-${b} ) $zip
  done
  chmod 440 *gz
  cd ..
done ; done
```



















##	QC



###	QC and Filter

Could filter the vcf with bcftools or other as well.

DS or HDS??? doesn't seem to make a difference.

export or recode vcf??? doesn't seem to make a difference.

Why plink2 instead of plink?

```BASH
for f in imputed-*/*dose.vcf.gz ; do
 b=${f%.dose.vcf.gz}
 echo "module load plink2; plink2 --threads 4 --vcf ${f} dosage=DS --maf 0.01 --hwe 1e-5 --geno 0.01 \
 --exclude-if-info 'R2 < 0.8' --out ${b}.QC --recode vcf bgz vcf-dosage=DS-force; \
  bcftools index --tbi ${b}.QC.vcf.gz; chmod -w ${b}.QC.vcf.gz ${b}.QC.vcf.gz.tbi"
done > plink_commands1

commands_array_wrapper.bash --array_file plink_commands1 --time 1-0 --threads 4 --mem 30G


#	or if the cluster's down login to n17 and ...
#	parallel -j 16 < plink_commands



#	X wasn't included in these data
#Error: chrX is present in the input file, but no sex information was provided;
#rerun this import with --psam or --update-sex.  --split-par may also be
#appropriate.
```

--set-all-var-ids chr@:#:\$r:\$a --new-id-max-allele-len 50

Using vcf-dosage=DS-force to set 0s? Nulls actually. Can mean 0, 1 or 2.




###	Concat

gonna take about a 2-6 hours

don't include X as not in all datasets?

Add the filter to PASS all. may be needed later by the gwasurvival script. not sure yet though. Don't think this mattered, but doesn't hurt.

gwasurvivr NEEDS the AF and DS tags to be Number=1 and NOT Number=A,
so split the multiallelics (if they exist) and manually set the types.


```BASH
for s in topmed umich ; do
for b in onco i370 tcga cidr ; do

 sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=concat-${s}-${b} \
   --export=None --output="${PWD}/concat-${s}-${b}.%j.$( date "+%Y%m%d%H%M%S%N" ).out" \
   --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
   --wrap="module load bcftools; bcftools concat --output - imputed-${s}-${b}/chr[1-9]{,?}.QC.vcf.gz | \
    bcftools norm --multiallelics - --output - -  | \
    sed -e 's/^##FORMAT=<ID=DS,Number=A,/##FORMAT=<ID=DS,Number=1,/' \
     -e 's/^##INFO=<ID=AF,Number=A,/##INFO=<ID=AF,Number=1,/' | \
    bcftools filter -s PASS -Oz -o imputed-${s}-${b}/concated.vcf.gz -Wtbi - ; \
    chmod -w imputed-${s}-${b}/concated.vcf.gz imputed-${s}-${b}/concated.vcf.gz.tbi"

done; done
```



### QC samples


export or recode?

DS or HDS?


```BASH
The longest observed allele code in this dataset has length 159. If you're fine
with the corresponding ID length, rerun with "--new-id-max-allele-len 159"
added to your command line.
```

Setting it to 200

plink2 sets DS back to Number=A, but not AF. Not sure if it merged any multiallelics.

Why plink2 instead of plink?


```BASH
for f in imputed-*/concated.vcf.gz ; do
 b=${f%.vcf.gz}
 echo "module load bcftools plink2 htslib; plink2 --threads 8 --vcf ${f} dosage=DS --output-chr chrM \
  --set-all-var-ids '@:#:\$r:\$a' --new-id-max-allele-len 200 --mind 0.01 --out ${b}.tmp.QC \
  --recode vcf bgz vcf-dosage=DS-force; \
  bcftools norm --multiallelics - --output - ${b}.tmp.QC.vcf.gz  | \
  sed -e 's/^##FORMAT=<ID=DS,Number=A,/##FORMAT=<ID=DS,Number=1,/' \
   -e 's/^##INFO=<ID=AF,Number=A,/##INFO=<ID=AF,Number=1,/' | \
  bgzip > ${b}.QC.vcf.gz; bcftools index --tbi ${b}.QC.vcf.gz ; \
  chmod -w ${b}.QC.vcf.gz ${b}.QC.vcf.gz.tbi; \rm ${b}.tmp.QC.vcf.gz"
done > plink_commands2

commands_array_wrapper.bash --array_file plink_commands2 --time 1-0 --threads 8 --mem 60G



#echo "module load plink2; plink2 --threads 8 --vcf ${f} dosage=DS --output-chr chrM \
#  --set-all-var-ids '@:#:\$r:\$a' --new-id-max-allele-len 200 --mind 0.01 --out ${b}.QC \
#  --recode vcf bgz vcf-dosage=DS-force; bcftools index --tbi ${b}.QC.vcf.gz; \
# chmod -w ${b}.QC.vcf.gz ${b}.QC.vcf.gz.tbi"
```







##	Survival GWAS






###	Make some lists



```BASH
mkdir lists
```

Link Geno's lists for reference
```BASH
ln -s /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_Onco_glioma_cases.txt lists/onco_glioma_cases.txt
ln -s /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/AGS_i370_glioma_cases.txt lists/i370_glioma_cases.txt
sort lists/onco_glioma_cases.txt > lists/onco_glioma_cases.sorted.txt
sort lists/i370_glioma_cases.txt > lists/i370_glioma_cases.sorted.txt

#	--- CIDR glioma case list
```


```BASH
FAM files ...
Family ID (FID): A unique identifier for the family the sample belongs to.
Individual ID (IID): A unique identifier for the individual within the family.
Paternal ID: The ID of the individual's father, or "0" if unknown or not in the dataset.
Maternal ID: The ID of the individual's mother, or "0" if unknown or not in the dataset.
Sex: A numerical code indicating the individual's sex (1=Male, 2=Female, 0=Unknown).
Phenotype: A numerical code indicating the sample's phenotype (1=Control, 2=Case, -9 or 0=Missing data).
```



hg38's fam files DO NOT INCLUDE Sex and Phenotype as they get lost in the liftover

Onco and I370
```BASH
awk '($6==2){print $1"_"$2}' hg19-onco/onco.fam > lists/onco-cases.txt
awk '($6==2){print $1"_"$2}' hg19-onco/onco.fam | sort > lists/onco-cases.sorted.txt
awk '($6==2){print $1"_"$2}' hg19-i370/i370.fam > lists/i370-cases.txt
awk '($6==2){print $1"_"$2}' hg19-i370/i370.fam | sort > lists/i370-cases.sorted.txt
```


My lists and Geno's lists are not identical. I presume some of his filtering removed some subjects. We shall see.



Just GBM and LGG normal samples.

```BASH
awk '($1~/^TCGA-(02|06|08|12|14|15|16|19|26|27|28|32|41|4W|65|74|76|81|87|CS|DB|DH|DU|E1|EZ|F6|FG|FN|HK|HT|HW|IK|KT|OX|P5|QH|R8|RR|RY|S9|TM|TQ|VM|VV|VW|W9|WH|WY)-....-10/){print $1"_"$2}' hg19-tcga/tcga.fam > lists/tcga-cases.txt
awk '($1~/^TCGA-(02|06|08|12|14|15|16|19|26|27|28|32|41|4W|65|74|76|81|87|CS|DB|DH|DU|E1|EZ|F6|FG|FN|HK|HT|HW|IK|KT|OX|P5|QH|R8|RR|RY|S9|TM|TQ|VM|VV|VW|W9|WH|WY)-....-10/){print $1"_"$2}' hg19-tcga/tcga.fam | sort > lists/tcga-cases.sorted.txt
```






NEED the CIDR case list

```BASH
awk '($2~/^G/){print $1"_"$2}' hg19-cidr/cidr.fam > lists/cidr-cases.txt
awk '($2~/^G/){print $1"_"$2}' hg19-cidr/cidr.fam | sort > lists/cidr-cases.txt


#grep -f <( awk -F, '($13==0){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv ) lists/cidr-cases.txt > lists/cidr_IDHwt_meta_cases.txt
#grep -f <( awk -F, '($13==0 && ($10==3 || $10==4)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv ) lists/cidr-cases.txt > lists/cidr_HGG_IDHwt_meta_cases.txt
#grep -f <( awk -F, '($13==0 && ($10==1 || $10==2)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv ) lists/cidr-cases.txt > lists/cidr_LrGG_IDHwt_meta_cases.txt
#
#grep -f <( awk -F, '($13==1){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv ) lists/cidr-cases.txt > lists/cidr_IDHmut_meta_cases.txt
#grep -f <( awk -F, '($13==1 && ($10==3 || $10==4)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv ) lists/cidr-cases.txt > lists/cidr_HGG_IDHmut_meta_cases.txt
#grep -f <( awk -F, '($13==1 && ($10==1 || $10==2)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv ) lists/cidr-cases.txt > lists/cidr_LrGG_IDHmut_meta_cases.txt
#
#grep -f <( awk -F, '($13==1 && ($12=="" || $12==0) && ($10==1 || $10==2)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv ) lists/cidr-cases.txt > lists/cidr_LrGG_IDHmut_1p19qintact_meta_cases.txt
#
#grep -f <( awk -F, '($13==1 && $12==1 && ($10==1 || $10==2)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_IPS_phenotype_2025-08-10_with_IPS_ID.csv ) lists/cidr-cases.txt > lists/cidr_LrGG_IDHmut_1p19qcodel_meta_cases.txt



awk -F, '($12==0){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.csv > lists/cidr_IDHwt_meta_cases.txt
awk -F, '($12==0 && ($9==3 || $9==4)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.csv > lists/cidr_HGG_IDHwt_meta_cases.txt
awk -F, '($12==0 && ($9==1 || $9==2)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.csv > lists/cidr_LrGG_IDHwt_meta_cases.txt

awk -F, '($12==1){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.csv > lists/cidr_IDHmut_meta_cases.txt
awk -F, '($12==1 && ($9==3 || $9==4)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.csv > lists/cidr_HGG_IDHmut_meta_cases.txt
awk -F, '($12==1 && ($9==1 || $9==2)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.csv > lists/cidr_LrGG_IDHmut_meta_cases.txt

awk -F, '($12==1 && ($11=="" || $11==0) && ($9==1 || $9==2)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.csv > lists/cidr_LrGG_IDHmut_1p19qintact_meta_cases.txt
awk -F, '($12==1 && $11==1 && ($9==1 || $9==2)){print $1}' /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.csv > lists/cidr_LrGG_IDHmut_1p19qcodel_meta_cases.txt

ln -s cidr-cases.txt lists/cidr_ALL_meta_cases.txt

```







Not sure about the cidr_LrGG_IDHmut_1p19qintact_meta_cases.txt list











These take about 3-4 hours

```BASH
for s in topmed umich ; do
for b in onco i370 tcga cidr ; do

  sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pull_dosage-${s}-${b} \
    --export=None --output="${PWD}/pull_dosage-${s}-${b}.%j.$( date "+%Y%m%d%H%M%S%N" ).out" \
    --time=1-0 --nodes=1 --ntasks=16 --mem=120G pull_case_dosage.bash \
    --IDfile ${PWD}/lists/${b}-cases.txt \
    --vcffile ${PWD}/imputed-${s}-${b}/concated.QC.vcf.gz --outbase ${PWD}/imputed-${s}-${b}

done; done
```





```
cd /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/

AGS_i370_HGG_IDHmut_meta_cases.txt
AGS_i370_HGG_IDHwt_meta_cases.txt
AGS_i370_IDHmut_meta_cases.txt
AGS_i370_IDHwt_meta_cases.txt
AGS_i370_LrGG_IDHmut_1p19qcodel_meta_cases.txt
AGS_i370_LrGG_IDHmut_1p19qintact_meta_cases.txt
AGS_i370_LrGG_IDHmut_meta_cases.txt
AGS_i370_LrGG_IDHwt_meta_cases.txt
AGS_Onco_HGG_IDHmut_meta_cases.txt
AGS_Onco_HGG_IDHwt_meta_cases.txt
AGS_Onco_IDHmut_meta_cases.txt
AGS_Onco_IDHwt_meta_cases.txt
AGS_Onco_LrGG_IDHmut_1p19qcodel_meta_cases.txt
AGS_Onco_LrGG_IDHmut_1p19qintact_meta_cases.txt
AGS_Onco_LrGG_IDHmut_meta_cases.txt
AGS_Onco_LrGG_IDHwt_meta_cases.txt
TCGA_HGG_IDHmut_meta_cases.txt
TCGA_HGG_IDHwt_meta_cases.txt
TCGA_IDHmut_meta_cases.txt
TCGA_IDHwt_meta_cases.txt
TCGA_LrGG_IDHmut_1p19qcodel_meta_cases.txt
TCGA_LrGG_IDHmut_1p19qintact_meta_cases.txt
TCGA_LrGG_IDHmut_meta_cases.txt
TCGA_LrGG_IDHwt_meta_cases.txt
```


```BASH
for f in /francislab/data1/users/gguerra/Pharma_TMZ_glioma/Data/*_meta_cases.txt ; do
l=$( basename ${f} )
l=${l/TCGA_/tcga_}
l=${l/AGS_Onco_/onco_}
l=${l/AGS_i370_/i370_}
\rm lists/${l}
cp ${f} lists/${l}
done

ln -s tcga-cases.txt lists/tcga_ALL_meta_cases.txt
ln -s i370-cases.txt lists/i370_ALL_meta_cases.txt
ln -s onco-cases.txt lists/onco_ALL_meta_cases.txt
```



We also need to copy the covariates files because at least one needs changed.

Onco has hospitals with apostrophes in the name which messes with the read.
Was a problem in gwasurvivr but not spacox read?

```BASH
awk 'BEGIN{FS=OFS="\t"}{
if( $1 ~ /^FAM_/ ){
gsub(/_/,"-",$1)
sub(/-/,"_",$1)
}
print
}' /francislab/data1/working/20210223-TCGA-GBMLGG-WTCCC-Affy6/20210305-covariates/TCGA_WTCCC_covariates.txt > lists/tcga_covariates.tsv

awk 'BEGIN{FS=OFS="\t"}{
if( $1 ~ /^0_WG/ ){
gsub(/_/,"-",$1)
sub(/-/,"_",$1)
}
print
}' /francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210305-covariates/AGS_Mayo_Oncoarray_covariates.txt \
| sed "s/'//g" > lists/onco_covariates.tsv

cp /francislab/data1/working/20210302-AGS-illumina/20210305-covariates/AGS_illumina_covariates.txt lists/i370_covariates.tsv


sed 's/,/\t/g' /francislab/data1/raw/20250813-CIDR/CIDR_case_covariates.csv > lists/cidr_covariates.tsv


chmod -w lists/*_covariates.tsv

```















i370 are all AGS

Could remove the tumors from the TCGA lists, but they aren't actually in the vcf so its unnecessary.

Correct the underscores in the onco lists AND IN THE COVARIATES FILE.

0_WG0238717-DNAC08_AGS55694



```BASH
sed -i '/^0_WG/s/_/-/g;s/-/_/' lists/onco*.txt
```






###	One time data correction

This no longer needs done.

plink2 QC set DS back to Number=A. Not sure if it remerged multiallelics though.

Quick correction rather than rerun. (This can take a couple hours.)

```BASH
#for vcf in imputed-*/*cases/*cases.vcf.gz imputed-*/concated.QC.vcf.gz ; do
#
#echo "module load htslib bcftools; chmod +w ${vcf} ${vcf}.tbi; \rm ${vcf}.tbi; gunzip ${vcf}; \
# sed -i -e 's/^##FORMAT=<ID=DS,Number=A,/##FORMAT=<ID=DS,Number=1,/' \
#  -e 's/^##INFO=<ID=AF,Number=A,/##INFO=<ID=AF,Number=1,/' ${vcf%.gz}; \
# bgzip ${vcf%.gz}; bcftools index --tbi ${vcf}; chmod -w ${vcf} ${vcf}.tbi"
#
#done > correction_commands
#
#commands_array_wrapper.bash --array_file correction_commands --time 1-0 --threads 4 --mem 30G
```









###	Recompute population estimate for PCs

Rather than use Geno's PCs, compute new ones from the QC'd dataset.

https://speciationgenomics.github.io/pca/

The PCs are only used in the case survival analysis so, only need the cases.

They take about 5-10 minutes

```BASH
for vcf in imputed-*/*cases/*cases.vcf.gz ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=4 --mem=30G \
 --export=None --job-name=$(dirname $(dirname $vcf)) \
 --wrap="module load plink; plink --vcf $vcf --indep-pairwise 50 10 0.1 --out ${vcf%.vcf.gz}; \
  plink --vcf $vcf --extract ${vcf%.vcf.gz}.prune.in --pca --out ${vcf%.vcf.gz}" \
 --out=${PWD}/plink_pca.$(dirname $(dirname $vcf)).log
done
```


```R
library(tidyverse)

for( f in Sys.glob("imputed-*/*cases/*cases.eigenvec") ) {
 pca <- read_table(f, col_names = FALSE)
 pca <- pca %>% unite(col = IID, X1, X2, sep = "_")
 names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))
 pca <-  pca[order(pca$IID), ]
 write_csv(pca, paste0(sub(".eigenvec", "", f),".pca.csv"))
}
```


Now we have multiple PCs for each dataset!!! Errrrrr.

Recreate covariate files with the PCs


DROP THE PC columns


```BASH
for b in onco i370 tcga ; do
 cov_in=lists/${b}_covariates.tsv
 cols=$( head -1 $cov_in | tr '\t' '\n' | wc -l )
 cat ${cov_in} | cut -f1-$((cols-20)) | tr -d , | tr '\t' , > $TMPDIR/tmp.csv
 head -1 ${TMPDIR}/tmp.csv > ${cov_in%.tsv}_base.csv
 tail -n +2 ${TMPDIR}/tmp.csv | sort -t, -k1,1 >> ${cov_in%.tsv}_base.csv
 for s in topmed umich ; do
  head -1 imputed-${s}-${b}/${b}-cases/${b}-cases.pca.csv > $TMPDIR/tmp.csv
  tail -n +2 imputed-${s}-${b}/${b}-cases/${b}-cases.pca.csv | sort -t, -k1,1 >> $TMPDIR/tmp.csv
  join --header -t, ${cov_in%.tsv}_base.csv $TMPDIR/tmp.csv | tr , '\t' > imputed-${s}-${b}/${b}-cases/${b}-covariates.tsv
done; done
```




CIDR's covariates don't include PCs
```BASH
b=cidr
cov_in=lists/${b}_covariates.tsv
cat ${cov_in} | tr -d , | tr '\t' , > $TMPDIR/tmp.csv
head -1 ${TMPDIR}/tmp.csv > ${cov_in%.tsv}_base.csv
tail -n +2 ${TMPDIR}/tmp.csv | sort -t, -k1,1 >> ${cov_in%.tsv}_base.csv
for s in topmed umich ; do
  head -1 imputed-${s}-${b}/${b}-cases/${b}-cases.pca.csv > $TMPDIR/tmp.csv
  tail -n +2 imputed-${s}-${b}/${b}-cases/${b}-cases.pca.csv | sort -t, -k1,1 >> $TMPDIR/tmp.csv
  join --header -t, ${cov_in%.tsv}_base.csv $TMPDIR/tmp.csv | tr , '\t' > imputed-${s}-${b}/${b}-cases/${b}-covariates.tsv
done
```















###	gwasurvivr.bash


Occassional completion with no results? Dataset is too small

```BASH
Analyzing chunk 108900-109000
Analysis completed on 2025-08-07 at 08:25:13
578 SNPs were removed from the analysis for not meeting the threshold criteria.
List of removed SNPs can be found in /scratch/gwendt/771767/i370_HGG_IDHmut_meta_cases.snps_removed
 SNPs were analyzed in total
The survival output can be found at /scratch/gwendt/771767/i370_HGG_IDHmut_meta_cases.coxph
+ ls -l /scratch/gwendt/771767/
total 114812
-rw-r----- 1 gwendt francislab    396101 Aug  7 07:35 AGS_illumina_covariates.txt
-rw-r----- 1 gwendt francislab 116942257 Aug  7 07:35 i370-cases.vcf.gz
-rw-r----- 1 gwendt francislab    166884 Aug  7 07:35 i370-cases.vcf.gz.tbi
-rw-r----- 1 gwendt francislab         1 Aug  7 08:10 i370_HGG_IDHmut_meta_cases.coxph
-rw-r----- 1 gwendt francislab     46046 Aug  7 08:25 i370_HGG_IDHmut_meta_cases.snps_removed
-rw-r-x--- 1 gwendt francislab       576 Aug  7 08:07 i370_HGG_IDHmut_meta_cases.txt
```



These take 4 to 26 hours. Really wish that the michiganCoxSurv was parallelizable.

May need to rerun the cidr_LrGG_IDHmut_1p19qintact_meta_cases.txt if I redefine it.

```BASH
for s in topmed umich ; do
for b in onco i370 tcga cidr ; do
for id in lists/${b}*meta_cases.txt ; do

echo gwasurvivr.bash --dataset ${b} --vcffile imputed-${s}-${b}/${b}-cases/${b}-cases.vcf.gz \
 --outbase ${PWD}/gwas-${s}-${b}/ \
 --idfile ${id} --covfile imputed-${s}-${b}/${b}-cases/${b}-covariates.tsv

done; done ; done > gwas_commands

commands_array_wrapper.bash --jobname gwasurvivr --array_file gwas_commands --time 2-0 --threads 2 --mem 15G
```




###	spacox.bash

Occassional failures. Dataset is too small is the usual cause.


SPA cox read in entire dosage file which can be large (30GB for topmed onco)
Will need memory to support this
umich i370 is only 3GB

For some reason, reading the transposed crashes so no need to do this. Too many columns?

```BASH
#for f in imputed-*/*/*dosage ; do
#echo "sed '1s/^/ /' $f | datamash transpose -t' ' | sed '1s/^ //' > ${f}.transposed; chmod -w ${f}.transposed"
#done > transpose_commands

#commands_array_wrapper.bash --array_file transpose_commands --time 1-0 --threads 16 --mem 120G
```

2/6 worked with 60G

3/6 needed 120G

1 needed 240G



This can take 15-60 mins

```BASH
for s in topmed umich ; do
for b in onco i370 tcga cidr ; do
for id in lists/${b}*meta_cases.txt ; do

echo spacox.bash --dataset ${b} --dosage imputed-${s}-${b}/${b}-cases/${b}-cases.dosage \
 --outbase ${PWD}/gwas-${s}-${b}/ \
 --idfile ${id} --covfile imputed-${s}-${b}/${b}-cases/${b}-covariates.tsv

done; done ; done > spa_commands

#	lists/${b}_covariates.tsv

commands_array_wrapper.bash --jobname spacox --array_file spa_commands --time 1-0 --threads 64 --mem 490G
```

60G isn't enough for many

490G is overkill but works for all





###	Merge

then merge those results

```BASH
for s in topmed umich ; do
for b in onco i370 tcga cidr ; do
for id in lists/${b}*meta_cases.txt ; do

echo merge_gwasurvivr_spacox.bash --dataset ${b} --outbase ${PWD}/gwas-${s}-${b}/ --idfile ${id}

done; done ; done > merge_commands

commands_array_wrapper.bash --jobname mergegwasspa --array_file merge_commands --time 1-0 --threads 2 --mem 15G
```






### METAL



I use the software METAL, which I downloaded to C4, its a very lightweight script, but does not seem to like being called in a shell script, .sh, I have always had to create .bash files and run those from the command line to get metal to loop over multiple analyses (e.g. multiple subtypes). 

You can find a very straightforward guide here: https://genome.sph.umich.edu/wiki/METAL_Documentation

Depending on which estimates are available, like the beta (effect size) or just p-values (like survival analysis using SPAcox would give), you must specify which mode to use. 

Easy examples of these differences are in the Script_Repository/metal folder of this Box container. 

I've built wrapper files which loop through all subtypes and call this script, see Pharma_surv_meta_wrapper_spa_all4.txt as an example. 

Using Beta estimates look at: script_Pharma_survival_metal_all4.txt


```BASH
for s in topmed umich ; do
for id in lists/onco*meta_cases.txt ; do

echo Pharma_surv_meta_wrapper_all4.bash $s $id

done ; done > metal_commands

commands_array_wrapper.bash --jobname metal --array_file metal_commands --time 1-0 --threads 4 --mem 30G
```





Using just P-values look at: script_Pharma_survival_metal_spa_all4.txt


```BASH
for s in topmed umich ; do
for id in lists/onco*meta_cases.txt ; do

echo Pharma_surv_meta_wrapper_spa_all4.bash $s $id

done ; done > metalspa_commands

commands_array_wrapper.bash --jobname metalspa --array_file metalspa_commands --time 1-0 --threads 4 --mem 30G
```































Add exit to r scripts when the sample count drops below a certain number?

Geno : I’d say anything running less than 30 individuals is very unreliable for survival models. Possibly the saddle point approximation in SPACox needs even more.


