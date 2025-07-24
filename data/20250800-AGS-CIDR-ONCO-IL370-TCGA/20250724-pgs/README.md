
#	20250800-AGS-CIDR-ONCO-IL370-TCGA/20250723-pgs

Use the prep from ../20250723-survival_gwas


```
ln -s ../20250723-survival_gwas/prep-onco
ln -s ../20250723-survival_gwas/prep-il370
ln -s ../20250723-survival_gwas/prep-cidr

mkdir prep-tcga
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.bed prep-tcga/tcga.bed
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.bim prep-tcga/tcga.bim
ln -s /francislab/data1/raw/20210223-TCGA-GBMLGG-WTCCC-Affy6/TCGA_WTCCC_for_QC.fam prep-tcga/tcga.fam
```



##	Create a frequency file


```BASH
for b in tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_freq --wrap="module load plink; plink --freq --bfile ${PWD}/prep-${b}/${b} --out ${PWD}/prep-${b}/${b};chmod -w ${PWD}/prep-${b}/${b}.frq" --out=${PWD}/prep-${b}/plink.create_frequency_file.log
done
```

##	Check BIM and split

```BASH
for b in tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_check-bim --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --bim ${PWD}/prep-${b}/${b}.bim --frequency ${PWD}/prep-${b}/${b}.frq --ref /francislab/data1/refs/Imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab --hrc" --out=${PWD}/prep-${b}/HRC-1000G-check-bim.pl.log
done
```

##	Run the generated script

```BASH
for b in tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_run-plink --wrap="module load plink; sh ${PWD}/prep-${b}/Run-plink.sh;\rm ${PWD}/prep-${b}/TEMP*" --out=${PWD}/prep-${b}/Run-plink.sh.log
done
```

##	Compress

```BASH
for b in tcga ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_bgzip --wrap="module load htslib; bgzip ${PWD}/prep-${b}/*vcf; chmod a-w ${PWD}/prep-${b}/*{bim,bed,fam,vcf.gz}" --out=${PWD}/prep-${b}/bgzip.log
done
```

That should be good.


##	Impute Genotypes for all 4 datasets


```
for b in onco il370 cidr tcga ; do
impute_pgs.bash -b hg19 -n 20250728-1kghg19-${b} -a apps@ancestry@1.0.0 -r apps@1000g-phase-3-v5@2.0.0 prep-${b}/${b}-updated-chr*.vcf.gz
impute_pgs.bash -b hg19 -n 20250728-1kghg38-${b} -a apps@ancestry@1.0.0 -r apps@1000g-phase3-deep@1.0.0 prep-${b}/${b}-updated-chr*.vcf.gz
done
```




##	Download

```
mkdir pgs-onco-hg19
cd pgs-onco-hg19

cd ..

mkdir pgs-il370-hg19
cd pgs-il370-hg19

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

mkdir pgs-il370-hg38
cd pgs-il370-hg38

cd ..

mkdir pgs-cidr-hg38
cd pgs-cidr-hg38

cd ..

mkdir pgs-tcga-hg38
cd pgs-tcga-hg38

cd ..
```



##	Prepare manifests


```
for b in onco il370 cidr tcga ; do
for r in hg19 hg38 ; do

awk 'BEGIN{FS=" ";OFS=","}(NR>1){cc=($6=="1")?"control":"case";sex=($5=="1")?"M":"F";print $1"_"$2,cc,sex }' prep-${b}/${b}.fam | sort -t, -k1,1 > pgs-${b}-${r}/mani.fest.csv
sed -i '1isubject,group,sex' pgs-${b}-${r}/mani.fest.csv

done ; done
```



include ancestry estimation PCs ...
```
for b in onco il370 cidr tcga ; do
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
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o topmed-both -p topmed-onco_1347 -p topmed-il370_4677 ${sex}"
done
```


