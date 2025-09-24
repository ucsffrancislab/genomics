
#	20250800-AGS-CIDR-ONCO-IL370-TCGA/20250724-pgs

Use the prep from ../20250723-survival_gwas


```BASH
ln -s ../20250723-survival_gwas/lists
ln -s ../20250723-survival_gwas/prep-onco-1000g
ln -s ../20250723-survival_gwas/prep-i370-1000g
ln -s ../20250723-survival_gwas/prep-cidr-1000g
ln -s ../20250723-survival_gwas/prep-tcga-1000g
```


##	Impute Genotypes for all 4 datasets


```BASH
for b in onco i370 cidr tcga ; do
impute_pgs.bash -f 0.8 -b hg19 -n 20250731-1kghg19-${b}-0.8 -a apps@ancestry@1.0.0 -r apps@1000g-phase-3-v5@2.0.0 prep-${b}-1000g/${b}-updated-chr*.vcf.gz
done
```

hg38 all fail with `Error: More than 100 allele switches have been detected. Imputation cannot be started!`

```BASH
#impute_pgs.bash -b hg19 -n 20250730-1kghg38-${b} -a apps@ancestry@1.0.0 -r apps@1000g-phase3-deep@1.0.0 prep-${b}-1000g/${b}-updated-chr*.vcf.gz
```




##	Download

TCGA failed to create report, but finished the PGS scores.

Rerunning a couple times.

```BASH
mkdir pgs-onco-hg19
cd pgs-onco-hg19
curl -sL https://imputationserver.sph.umich.edu/get/lQit9YyhMuFA36VSLmC2YcQcMs0e9oLDngN7SjJ0 | bash
chmod -w *
cd ..

mkdir pgs-i370-hg19
cd pgs-i370-hg19
curl -sL https://imputationserver.sph.umich.edu/get/FuEICxRjFAWZTpwlVrinM8oNfvCrRXvwd2O5tWLH | bash
chmod -w *
cd ..

mkdir pgs-tcga-hg19
cd pgs-tcga-hg19
curl -sL https://imputationserver.sph.umich.edu/get/Vd8al3eLAedEV64Izo6WVjAKO3t78JDmfaKmVLD0 | bash
chmod -w *
cd ..

mkdir pgs-cidr-hg19
cd pgs-cidr-hg19
curl -sL https://imputationserver.sph.umich.edu/get/4qETYKSztetEmZIFT0P2dajzEjTs3hqWjTPUZ0oR | bash
chmod -w *
cd ..
```



##	Prepare manifests

```BASH
Family ID (FID): A unique identifier for the family the sample belongs to.
Individual ID (IID): A unique identifier for the individual within the family.
Paternal ID: The ID of the individual's father, or "0" if unknown or not in the dataset.
Maternal ID: The ID of the individual's mother, or "0" if unknown or not in the dataset.
Sex: A numerical code indicating the individual's sex (1=Male, 2=Female, 0=Unknown).
Phenotype: A numerical code indicating the sample's phenotype (1=Control, 2=Case, -9 or 0=Missing data).

FAM files ...
Sex code ('1' = male, '2' = female, '0' = unknown)
Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)
```




hg38's fam files DO NOT INCLUDE Sex and Phenotype as they get lost in the liftover.
Why does this matter? I'm not using them am I?

(previously I skipped the first line. thought it included a header?)

Onco and I370
```BASH
for b in onco i370 cidr ; do
for r in hg19 ; do

awk 'BEGIN{FS=" ";OFS=","}{cc=($6=="1")?"control":"case";sex=($5=="1")?"M":"F";print $1"_"$2,cc,sex }' prep-${b}-1000g/${b}.fam | sort -t, -k1,1 > pgs-${b}-${r}/mani.fest.csv
sed -i '1isubject,group,sex' pgs-${b}-${r}/mani.fest.csv

done ; done
```


TCGA cases are JUST THE BLOOD NORMAL? Not the SOLID NORMAL (just 1 sample)? Not the TUMOR? Correct?

```BASH
awk -F"\t" '($3=="Glioblastoma multiforme" || $3=="Brain Lower Grade Glioma"){print $1}' /francislab/data1/refs/TCGA/TCGA.Tissue_Source_Site_Codes.tsv | paste -sd\|
02|06|08|12|14|15|16|19|26|27|28|32|41|4W|65|74|76|81|87|CS|DB|DH|DU|E1|EZ|F6|FG|FN|HK|HT|HW|IK|KT|OX|P5|QH|R8|RR|RY|S9|TM|TQ|VM|VV|VW|W9|WH|WY
```

TCGA fam file does not contain any "2" for sex? Gonna need to search.

/francislab/data1/refs/TCGA/TCGA.Glioma.metadata.tsv 


Missing sex for ...
```BASH
TCGA-16-1048-10A_TCGA-16-1048-10A,case,F
TCGA-28-2501-10A_TCGA-28-2501-10A,case,F
TCGA-28-2510-10A_TCGA-28-2510-10A,case,F
TCGA-R8-A6YH-10B_TCGA-R8-A6YH-10B,case,F
```



```BASH
b=tcga
r=hg19

#awk 'BEGIN{FS=" ";OFS=","}{cc=($1~/^TCGA-..-....-10/)?"case":"control";sex=($5=="1")?"M":"F";print $1"_"$2,cc,sex }' prep-${b}-1000g/${b}.fam | sort -t, -k1,1 > pgs-${b}-${r}/mani.fest.tmp


awk 'BEGIN{FS=" ";OFS=","}{cc=($1~/^TCGA-/)?"ignore":"control";if($1~/^TCGA-(02|06|08|12|14|15|16|19|26|27|28|32|41|4W|65|74|76|81|87|CS|DB|DH|DU|E1|EZ|F6|FG|FN|HK|HT|HW|IK|KT|OX|P5|QH|R8|RR|RY|S9|TM|TQ|VM|VV|VW|W9|WH|WY)-....-10/)cc="case";sex=($5=="1")?"M":"F";print $1"_"$2,cc,sex }' prep-${b}-1000g/${b}.fam | sort -t, -k1,1 > pgs-${b}-${r}/mani.fest.tmp

while read subject group sex; do 
  if [[ "${subject}" =~ ^TCGA ]] ; then
    base=${subject:0:12}
    sex=$( awk -F"\t" -v base=${base} '($1==base){print $6}' /francislab/data1/refs/TCGA/TCGA.Glioma.metadata.tsv )
    if [ "${sex}" == "male" ] ; then
      sex="M"
    elif [ "${sex}" == "female" ] ; then
      sex="F"
    else
      sex="U"
    fi
  fi
  echo "${subject},${group},${sex}"
done < <( cat pgs-${b}-${r}/mani.fest.tmp | tr ',' ' ' ) > pgs-${b}-${r}/mani.fest.csv

sed -i '1isubject,group,sex' pgs-${b}-${r}/mani.fest.csv
```




CIDR's hg19 is a liftover and doesn't have sex. Neither fam files have case/control.

```BASH
ln -s ../20250723-survival_gwas/prep-cidr-TOPMed
b=cidr
r=hg19

awk 'BEGIN{FS=" ";OFS=","}{cc=($2~"^G")?"case":"control";sex=($5=="1")?"M":"F";print $1"_"$2,cc,sex }' prep-${b}-TOPMed/${b}.fam | sort -t, -k1,1 > pgs-${b}-${r}/mani.fest.csv
sed -i '1isubject,group,sex' pgs-${b}-${r}/mani.fest.csv
```





include ancestry estimation PCs ...
```
for b in onco i370 cidr tcga ; do
for r in hg19 ; do

head -1 pgs-${b}-${r}/estimated-population.txt > pgs-${b}-${r}/estimated-population.sorted.txt
tail -n +2 pgs-${b}-${r}/estimated-population.txt | sort -k1,1 >> pgs-${b}-${r}/estimated-population.sorted.txt
sed -i 's/\t/,/g' pgs-${b}-${r}/estimated-population.sorted.txt
join --header -t, pgs-${b}-${r}/mani.fest.csv pgs-${b}-${r}/estimated-population.sorted.txt > pgs-${b}-${r}/manifest.estimated-population.csv

done ; done
```







##	Compare Case/Control



```BASH
for b in onco i370 cidr tcga ; do

for sex in "" "--sex M" "--sex F" ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-${b}-${sex#--sex } \
  --export=None --output=${PWD}/pgs-${b}-${sex#--sex }.$( date "+%Y%m%d%H%M%S%N" ).out \
  --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o pgs-${b}-hg19 -p pgs-${b}-hg19 ${sex}"

done
done


mkdir pgs-all

for sex in "" "--sex M" "--sex F" ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-all-${sex#--sex } \
  --export=None --output=${PWD}/pgs-all-${sex#--sex }.$( date "+%Y%m%d%H%M%S%N" ).out \
  --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o pgs-all -p pgs-i370-hg19 -p pgs-onco-hg19 -p pgs-tcga-hg19 -p pgs-cidr-hg19 ${sex}"
done
```



##	Rename results and share

```BASH
mkdir results
for b in onco i370 cidr tcga ; do
for sex in "" M F ; do
cp pgs-${b}-hg19/PGS_Case_Control_Score_Comparison-scores-case-control-Prop_test_results-sex-${sex}.csv results/PGS_Case_Control-${b}-sex-${sex}.csv
done
done
for sex in "" M F ; do
cp pgs-all/PGS_Case_Control_Score_Comparison-scores-case-control-Prop_test_results-sex-${sex}.csv results/PGS_Case_Control-All-sex-${sex}.csv
done
```


```BASH
box_upload.bash results/PGS_Case_Control-*
```














##	PGS Survival Analysis

Extract just cases from PGS matrix

```BASH
for b in onco i370 tcga ; do

  sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pull_pgs-${b} \
    --output="${PWD}/pull_pgs-${b}.%j.$( date "+%Y%m%d%H%M%S%N" ).out" \
    --time=1-0 --nodes=1 --ntasks=4 --mem=30G pull_case_pgs.bash \
    --IDfile ${PWD}/lists/${b}-cases.txt \
    --pgsfile ${PWD}/pgs-${b}-hg19/scores.txt --outbase ${PWD}/pgs-${b}-hg19

done
```



```BASH
for b in onco i370 tcga ; do
 cov_in=lists/${b}_covariates.tsv
 cols=$( head -1 $cov_in | tr '\t' '\n' | wc -l )
 cat ${cov_in} | cut -f1-$((cols-20)) | tr -d , | tr '\t' , > $TMPDIR/tmp.csv
 head -1 ${TMPDIR}/tmp.csv > pgs-${b}-hg19/${b}-covariates_base.csv
 tail -n +2 ${TMPDIR}/tmp.csv | sort -t, -k1,1 >> pgs-${b}-hg19/${b}-covariates_base.csv
 cat pgs-${b}-hg19/estimated-population.sorted.txt | cut -d, -f1,5- > $TMPDIR/tmp.csv
 join --header -t, pgs-${b}-hg19/${b}-covariates_base.csv $TMPDIR/tmp.csv | tr , '\t' > pgs-${b}-hg19/${b}-covariates.tsv
done
```



```BASH
for b in onco i370 tcga ; do
for id in lists/${b}*meta_cases.txt ; do

echo spacox.bash --dataset ${b} --dosage pgs-${b}-hg19/case_scores.csv \
 --outbase ${PWD}/pgs-${b}-hg19/ \
 --idfile ${id} --covfile pgs-${b}-hg19/${b}-covariates.tsv

done; done > spa_commands

commands_array_wrapper.bash --array_file spa_commands --time 1-0 --threads 4 --mem 30G
```




##	20250820



```BASH
for b in onco i370 tcga ; do
cat pgs-${b}-hg19/case_scores.csv | datamash transpose -t ' ' --output-delimiter=, > pgs-${b}-hg19/case_scores.t.csv
cat pgs-${b}-hg19/${b}-covariates.tsv | tr '\t' ',' > pgs-${b}-hg19/${b}-covariates.csv
join --header -t, pgs-${b}-hg19/${b}-covariates.csv pgs-${b}-hg19/case_scores.t.csv > pgs-${b}-hg19/${b}-covariates-scores.csv
done

extract_cox_coeffs_for_pgs.r
```






pgs-${b}-hg19/${b}-covariates-scores.csv



```BASH
for b in onco i370 tcga ; do
for id in lists/${b}*meta_cases.txt ; do

echo pgscox.bash --dataset ${b} --pgsscores pgs-${b}-hg19/scores.txt \
 --outbase ${PWD}/pgs-${b}-hg19/ \
 --idfile ${id} --covfile pgs-${b}-hg19/${b}-covariates.tsv

done; done > cox_commands

commands_array_wrapper.bash --array_file cox_commands --time 1-0 --threads 4 --mem 30G
```


Use METAL to analyze all 3 datasets together.

```BASH
for id in lists/onco*meta_cases.txt ; do

echo survival_metal_wrapper_all3.bash $id

done > metal_commands

commands_array_wrapper.bash --array_file metal_commands --time 1-0 --threads 4 --mem 30G
```


