

#	20250700-AGS-CIDR-ONCO-Illumina/20250618-quick_test


AGS
Impute and analyse separately
Meta analysis scripts from Geno - survival gwas



```BASH
for b in il370_4677 onco_1347 ; do
mkdir prep-${b}
for f in /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/${b}.{bed,bim,fam} ; do
ln -s ${f} prep-${b}/
done
done
```


##	Create a frequency file


```BASH
for b in il370_4677 onco_1347 ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_freq --wrap="module load plink; plink --freq --bfile ${PWD}/prep-${b}/${b} --out ${PWD}/prep-${b}/${b};chmod -w ${PWD}/prep-${b}/${b}.frq" --out=${PWD}/prep-${b}/plink.create_frequency_file.log
done
```

##	Check BIM and split

```BASH
for b in il370_4677 onco_1347 ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_check-bim --wrap="perl /francislab/data1/refs/Imputation/HRC-1000G-check-bim.pl --bim ${PWD}/prep-${b}/${b}.bim --frequency ${PWD}/prep-${b}/${b}.frq --ref /francislab/data1/refs/Imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab --hrc" --out=${PWD}/prep-${b}/HRC-1000G-check-bim.pl.log
done
```

##	Run the generated script

```BASH
for b in il370_4677 onco_1347 ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_run-plink --wrap="module load plink; sh ${PWD}/prep-${b}/Run-plink.sh;\rm ${PWD}/prep-${b}/TEMP*" --out=${PWD}/prep-${b}/Run-plink.sh.log
done
```

##	Compress

```BASH
for b in il370_4677 onco_1347 ; do
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 14-0 --nodes=1 --ntasks=4 --mem=30G --export=None --job-name=${b}_bgzip --wrap="module load htslib; bgzip ${PWD}/prep-${b}/*vcf; chmod a-w ${PWD}/prep-${b}/*{bim,bed,fam,vcf.gz}" --out=${PWD}/prep-${b}/bgzip.log
done
```

That should be good.


##	20250627 - Impute Genotypes with TOPMed

```
impute_genotypes.bash -n 20250627-onco  prep-onco_1347/onco_1347-updated-chr*.vcf.gz
impute_genotypes.bash -n 20250627-il370 prep-il370_4677/il370_4677-updated-chr*.vcf.gz
```


##	20250629

```
mkdir topmed-onco_1347
cd topmed-onco_1347
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1677934/af04499a3cdbaffeb3fdbbf5faafd53c410b2fcc929063fedc38cfb00e88e3cd | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1677938/ddaea57f9ba7713cd08c5cece401077190155e17af65e0b7262ea2df8ce48f8c | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1677941/bf477d3ed7974bd4404506ba0e31782303c570c3637bc3eb4c8226524deae659 | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1677940/81a64c9573afd37548d49caca95c70762c97a27305cab180368147ca74364aca | bash
cd ..


mkdir topmed-il370_4677
cd topmed-il370_4677
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1677958/b6151eea5ff4e7b76a28ee02f147b0292885dd95ad8dec85fbb8644b1c59618c | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1677962/60a415ba4fadd3c9b05d916711e9454a13d90279ecdb37c2b385a5c55e5bc465 | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1677965/3c0c0d88f1fb6d2593af1246dabb4e02ec495ed444fe30c3bd3dc9ca014cb701 | bash
curl -sL https://imputation.biodatacatalyst.nhlbi.nih.gov/get/1677964/f731623a161ac1dbff1ee3e6f23b85430651036cbbe17c6ec321294a15e56ef7 | bash
cd ..

chmod -w topmed-*/*
```


```
cd topmed-il370_4677
chmod a-w *
for zip in chr*zip ; do
echo $zip
unzip -P $( cat ../password-il370 ) $zip
done
chmod 440 *gz

cd ../topmed-onco_1347
chmod a-w *
for zip in chr*zip ; do
echo $zip
unzip -P $( cat ../password-onco ) $zip
done
chmod 440 *gz
cd ..
```





##	20250628

```

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=nextflow-onco \
  --export=None --output="${PWD}/nextflow-onco_1347.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load openjdk; nextflow run ~/github/genepi/imputationserver2/main.nf -config ${PWD}/imputation_and_pgs-onco_1347.config"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=nextflow-il370 \
  --export=None --output="${PWD}/nextflow-il370_4677.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load openjdk; nextflow run ~/github/genepi/imputationserver2/main.nf -config ${PWD}/imputation_and_pgs-il370_4677.config"

```


Failed. Still deving.



##	20250630



```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=concat-il370 \
  --export=None --output="${PWD}/concat-il370.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="cd topmed-il370_4677;bcftools concat -W TBI -o complete.vcf.gz -Oz chr[1-9].dose.vcf.gz chr??.dose.vcf.gz chrX.dose.vcf.gz"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=concat-onco \
  --export=None --output="${PWD}/concat-onco.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="cd topmed-onco_1347;bcftools concat -W TBI -o complete.vcf.gz -Oz chr[1-9].dose.vcf.gz chr??.dose.vcf.gz chrX.dose.vcf.gz"

```






##	20250701

Test gwas scripts, first on old data, then on new.
The new data is HUGE so not sure why the huge diff. No notes on what Geno filtered.


```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=gwas-onco \
  --export=None --output="${PWD}/gwas-onco.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=14-0 --nodes=1 --ntasks=2 --mem=15G GWAsurvivr_shell.sh

```
Outputs to GWAStest




##	20250703

```
for chrnum in {1..22} X ; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-onco_1347-${chrnum} \
  --export=None --output="${PWD}/pgs-onco_1347-${chrnum}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk; java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply /francislab/data1/working/20250700-AGS-CIDR-ONCO-IL370/20250618-quick_test/topmed-onco_1347/chr${chrnum}.dose.vcf.gz --ref /francislab/data1/refs/Imputation/PGSCatalog/hg38/pgs-collection.txt.gz --out /francislab/data1/working/20250700-AGS-CIDR-ONCO-IL370/20250618-quick_test/topmed-onco_1347/chr${chrnum}.dose.scores.txt --info /francislab/data1/working/20250700-AGS-CIDR-ONCO-IL370/20250618-quick_test/topmed-onco_1347/chr${chrnum}.dose.scores.info --min-r2 0 --no-ansi --threads 8"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-il370_4677-${chrnum} \
  --export=None --output="${PWD}/pgs-il370_4677-${chrnum}.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk; java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar apply /francislab/data1/working/20250700-AGS-CIDR-ONCO-IL370/20250618-quick_test/topmed-il370_4677/chr${chrnum}.dose.vcf.gz --ref /francislab/data1/refs/Imputation/PGSCatalog/hg38/pgs-collection.txt.gz --out /francislab/data1/working/20250700-AGS-CIDR-ONCO-IL370/20250618-quick_test/topmed-il370_4677/chr${chrnum}.dose.scores.txt --info /francislab/data1/working/20250700-AGS-CIDR-ONCO-IL370/20250618-quick_test/topmed-il370_4677/chr${chrnum}.dose.scores.info --min-r2 0 --no-ansi --threads 8"

done
```


TOPMed imputed results are hg38 !!!!!!

```
  java -Xmx${avail_mem}M -jar /opt/pgs-calc/pgs-calc.jar \
      merge-score ${score_chunks} \
      --out scores.txt

  java -Xmx${avail_mem}M -jar /opt/pgs-calc/pgs-calc.jar \
      merge-info ${report_chunks} \
      --out scores.info
```


##	20250703 - Impute PGS with UMich

Really only doing this for the estimated ancestry

```
impute_pgs.bash -b hg19 -n 20250703-onco  -a apps@ancestry@1.0.0 -r apps@1000g-phase-3-v5@2.0.0 prep-onco_1347/onco_1347-updated-chr*.vcf.gz
impute_pgs.bash -b hg19 -n 20250703-il370 -a apps@ancestry@1.0.0 -r apps@1000g-phase-3-v5@2.0.0 prep-il370_4677/il370_4677-updated-chr*.vcf.gz

```


```
mkdir pgs-onco_1347
cd pgs-onco_1347
curl -sL https://imputationserver.sph.umich.edu/get/zr1KOkynixO15vFMHRAwQS5DCtTMPsz4kGydKgLH | bash
cd ..


mkdir pgs-il370_4677
cd pgs-il370_4677
curl -sL https://imputationserver.sph.umich.edu/get/QDakrXuQNpSKaF8PfwsphEptBwli0LvWlUv71Dde | bash
cd ..
```





##	20250704


Prepping to compare PGS scores.

Creating a manifest

subject,group,sex,plate

Sex code ('1' = male, '2' = female, '0' = unknown)

Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)



Keep it super simple at first: subject, group, sex




head /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/il370_4677.fam
AGS51842 AGS51842 0 0 2 2
AGS42569 AGS42569 0 0 2 2
AGS44958 AGS44958 0 0 2 2
AGS48861 AGS48861 0 0 1 2
AGS50675 AGS50675 0 0 1 2
AGS53733 AGS53733 0 0 2 2
AGS41687 AGS41687 0 0 2 2
AGS48742 AGS48742 0 0 1 2
AGS52123 AGS52123 0 0 1 2
AGS52991 AGS52991 0 0 2 2

head /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/onco_1347.fam
0 WG0238624-DNAA02_AGS51641 0 0 2 2
0 WG0238624-DNAA03_AGS40548 0 0 1 2
0 WG0238624-DNAA04_AGS44682 0 0 2 2
0 WG0238624-DNAA05_AGS50011 0 0 2 2
0 WG0238624-DNAA06_AGS47844 0 0 1 2
0 WG0238624-DNAA07_AGS41323 0 0 2 2
0 WG0238624-DNAA08_AGS48652 0 0 2 2

covariates


```
awk 'BEGIN{FS=" ";OFS=","}(NR>1){cc=($6=="1")?"control":"case";sex=($5=="1")?"M":"F";print $1"_"$2,cc,sex }' /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/il370_4677.fam | sort -t, -k1,1 > pgs-il370_4677/mani.fest.csv
sed -i '1isubject,group,sex' pgs-il370_4677/mani.fest.csv

awk 'BEGIN{FS=" ";OFS=","}(NR>1){cc=($6=="1")?"control":"case";sex=($5=="1")?"M":"F";print $1"_"$2,cc,sex }' /francislab/data1/raw/20200520_Adult_Glioma_Study_GWAS/onco_1347.fam | sort -t, -k1,1 > pgs-onco_1347/mani.fest.csv
sed -i '1isubject,group,sex' pgs-onco_1347/mani.fest.csv
```



head pgs-onco_1347/estimated-population.txt 
sample	population	voting_popluation	voting	PC1	PC2	PC3	PC4	PC5	PC6	PC7	PC8
0_WG0238624-DNAE07_AGS42769	EUR	EUR	1.0	17.5113	202.74	-10.944	-14.7951	32.6872	-37.3633	-99.2664	12.1314
0_WG0238624-DNAE09_AGS41180	EUR	EUR	1.0	14.752	200.952	-5.18382	-14.4075	34.4554	-35.123	-95.708	14.8371
0_WG0238624-DNAE10_AGS50604	EUR	EUR	1.0	17.5014	204.703	-14.9696	-11.1781	30.6981	-35.7657	-100.49	15.7955
0_WG0238624-DNAE11_AGS49802	Unknown	EUR	0.6225370264701632	39.8801	194.862	6.1637	-13.1552	33.1813	-18.3372	0.723905	5.05315

head pgs-il370_4677/estimated-population.txt 
sample	population	voting_popluation	voting	PC1	PC2	PC3	PC4	PC5	PC6	PC7	PC8
1813290467_A_1813290467_A	EUR	EUR	1.0	-7.59162	152.822	-54.6788	-3.36749	35.2858	-30.7465	-78.6284	3.82209
1813290539_A_1813290539_A	EUR	EUR	1.0	16.9331	199.9	-10.0939	-15.6042	31.6	-30.9729	-85.2272	14.3014
1813290573_A_1813290573_A	EUR	EUR	1.0	19.5154	207.924	-17.4724	-13.575	27.5996	-34.9471	-95.9314	15.362
1813290574_A_1813290574_A	EUR	EUR	1.0	20.7636	200.336	-10.3775	-14.9067	40.0397	-35.8365	-96.7785	22.2155
1814233016_A_1814233016_A	EUR	EUR	1.0	33.1509	205.22	0.892959	-12.5947	44.9077	-21.523	-19.7315	13.7803
1814233017_A_1814233017_A	EUR	EUR	1.0	27.3623	203.445	-10.9206	-13.4541	32.8553	-35.4737	-98.4196	10.6549
1814233027_A_1814233027_A	EUR	EUR	1.0	27.3378	199.925	-0.639814	-19.2128


head pgs-onco_1347/scores.txt | cut -c1-50
"sample","PGS000008","PGS000006","PGS000005","PGS0
"0_WG0238624-DNAA02_AGS51641","-0.5887306867352535
"0_WG0238624-DNAA03_AGS40548","0.27848094657881006
"0_WG0238624-DNAA04_AGS44682","-0.7464020634819661
"0_WG0238624-DNAA05_AGS50011","-0.4075961553666758
"0_WG0238624-DNAA06_AGS47844","-0.4224025107694587
"0_WG0238624-DNAA07_AGS41323","-0.704195975089327"
"0_WG0238624-DNAA08_AGS48652","-0.0926888040885884


head pgs-il370_4677/scores.txt | cut -c1-50
"sample","PGS000008","PGS000006","PGS000005","PGS0
"AGS51842_AGS51842","-1.1587561513898166","-1.2062
"AGS42569_AGS42569","0.4386154399283697","0.418649
"AGS44958_AGS44958","0.4769612098996987","0.010230
"AGS48861_AGS48861","0.5201518451072928","0.160453
"AGS50675_AGS50675","-0.3192810183764436","0.71262
"AGS53733_AGS53733","-0.3674554843926856","-0.1943



include ancestry estimation PC1-3 ....
```
head -1 pgs-onco_1347/estimated-population.txt > pgs-onco_1347/estimated-population.sorted.txt
tail -n +2 pgs-onco_1347/estimated-population.txt | sort -k1,1 >> pgs-onco_1347/estimated-population.sorted.txt
sed -i 's/\t/,/g' pgs-onco_1347/estimated-population.sorted.txt
join --header -t, pgs-onco_1347/mani.fest.csv pgs-onco_1347/estimated-population.sorted.txt > pgs-onco_1347/manifest.estimated-population.csv

head -1 pgs-il370_4677/estimated-population.txt > pgs-il370_4677/estimated-population.sorted.txt
tail -n +2 pgs-il370_4677/estimated-population.txt | sort -k1,1 >> pgs-il370_4677/estimated-population.sorted.txt
sed -i 's/\t/,/g' pgs-il370_4677/estimated-population.sorted.txt
join --header -t, pgs-il370_4677/mani.fest.csv pgs-il370_4677/estimated-population.sorted.txt > pgs-il370_4677/manifest.estimated-population.csv

```

edit PGS_Case_Control_Score_Regression.R to check for the existance of columns: plate, PC1, PC2, PC3


```
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-onco_1347- \
  --export=None --output="${PWD}/pgs-onco_1347-.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o pgs-onco_1347 -p pgs-onco_1347"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-onco_1347-F \
  --export=None --output="${PWD}/pgs-onco_1347-F.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o pgs-onco_1347 -p pgs-onco_1347 --sex F"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-onco_1347-M \
  --export=None --output="${PWD}/pgs-onco_1347-M.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o pgs-onco_1347 -p pgs-onco_1347 --sex M"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-il370_4677- \
  --export=None --output="${PWD}/pgs-il370_4677-.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o pgs-il370_4677 -p pgs-il370_4677"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-il370_4677-F \
  --export=None --output="${PWD}/pgs-il370_4677-F.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o pgs-il370_4677 -p pgs-il370_4677 --sex F"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-il370_4677-M \
  --export=None --output="${PWD}/pgs-il370_4677-M.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=2 --mem=15G \
  --wrap="module load r;PGS_Case_Control_Score_Regression.R -a case -b control --zfile_basename scores.txt -o pgs-il370_4677 -p pgs-il370_4677 --sex M"
```






