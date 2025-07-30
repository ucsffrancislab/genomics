
#	20250800-AGS-CIDR-ONCO-IL370-TCGA/20250723-pgs

Use the prep from ../20250723-survival_gwas


```
ln -s ../20250723-survival_gwas/prep-onco
ln -s ../20250723-survival_gwas/prep-i370
ln -s ../20250723-survival_gwas/prep-cidr
ln -s ../20250723-survival_gwas/prep-tcga

```


##	Impute Genotypes for all 4 datasets


```
for b in onco i370 cidr tcga ; do
impute_pgs.bash -b hg19 -n 20250728-1kghg19-${b} -a apps@ancestry@1.0.0 -r apps@1000g-phase-3-v5@2.0.0 prep-${b}/${b}-updated-chr*.vcf.gz
impute_pgs.bash -b hg19 -n 20250728-1kghg38-${b} -a apps@ancestry@1.0.0 -r apps@1000g-phase3-deep@1.0.0 prep-${b}/${b}-updated-chr*.vcf.gz
done
```




##	Download

```
mkdir pgs-onco-hg19
cd pgs-onco-hg19

cd ..

mkdir pgs-i370-hg19
cd pgs-i370-hg19

cd ..

mkdir pgs-cidr-hg19
cd pgs-cidr-hg19

cd ..

mkdir pgs-tcga-hg19
cd pgs-tcga-hg19

cd ..

mkdir pgs-onco-hg38
cd pgs-onco-hg38

cd ..

mkdir pgs-i370-hg38
cd pgs-i370-hg38

cd ..

mkdir pgs-cidr-hg38
cd pgs-cidr-hg38

cd ..

mkdir pgs-tcga-hg38
cd pgs-tcga-hg38

cd ..
```



##	Prepare manifests


Family ID (FID): A unique identifier for the family the sample belongs to.
Individual ID (IID): A unique identifier for the individual within the family.
Paternal ID: The ID of the individual's father, or "0" if unknown or not in the dataset.
Maternal ID: The ID of the individual's mother, or "0" if unknown or not in the dataset.
Sex: A numerical code indicating the individual's sex (1=Male, 2=Female, 0=Unknown).
Phenotype: A numerical code indicating the sample's phenotype (1=Control, 2=Case, -9 or 0=Missing data).

FAM files ...
Sex code ('1' = male, '2' = female, '0' = unknown)
Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)



I could certainly ignore the 01s
only use the 10s as cases


THIS FAM FILE DOES NOT HAVE CASE/CONTROL
Set all of the TCGA-..-....-10. as case
All else are control


```
for b in onco i370 cidr tcga ; do
for r in hg19 hg38 ; do

awk 'BEGIN{FS=" ";OFS=","}(NR>1){cc=($6=="1")?"control":"case";sex=($5=="1")?"M":"F";print $1"_"$2,cc,sex }' prep-${b}/${b}.fam | sort -t, -k1,1 > pgs-${b}-${r}/mani.fest.csv
sed -i '1isubject,group,sex' pgs-${b}-${r}/mani.fest.csv

done ; done
```



include ancestry estimation PCs ...
```
for b in onco i370 cidr tcga ; do
for r in hg19 hg38 ; do

head -1 pgs-${b}-${r}/estimated-population.txt > pgs-${b}-${r}/estimated-population.sorted.txt
tail -n +2 pgs-${b}-${r}/estimated-population.txt | sort -k1,1 >> pgs-${b}-${r}/estimated-population.sorted.txt
sed -i 's/\t/,/g' pgs-${b}-${r}/estimated-population.sorted.txt
join --header -t, pgs-${b}-${r}/mani.fest.csv pgs-${b}-${r}/estimated-population.sorted.txt > pgs-${b}-${r}/manifest.estimated-population.csv

done ; done
```






---


EDIT


##	Compare Case/Control

```
mkdir topmed-both

for sex in "" "--sex M" "--sex F" ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=topmed-both-${sex#--sex } \
  --export=None --output="${PWD}/topmed-both-${sex#--sex }.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o topmed-both -p topmed-onco_1347 -p topmed-i370_4677 ${sex}"
done
```


