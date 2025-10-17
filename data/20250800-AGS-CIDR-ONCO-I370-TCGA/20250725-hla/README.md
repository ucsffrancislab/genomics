
#	20250800-AGS-CIDR-ONCO-IL370-TCGA/20250725-hla



Use the prep from ../20250723-survival_gwas and ../20250724-pgs


```BASH
ln -s ../20250724-pgs/prep-onco-1000g
ln -s ../20250724-pgs/prep-i370-1000g
ln -s ../20250724-pgs/prep-cidr-1000g
ln -s ../20250724-pgs/prep-tcga-1000g
```


##  Impute HLA for all 4 datasets

If upload more than just chr6, you get failures like ...
```
Reference Panel: multiethnic-hla-panel (hg19)
Task 'Calculating QC Statistics This reference panel doesn't support chromosome 1. File ./1.sites.gz not found.

Reference Panel: multiethnic-hla-panel (hg19)
Task 'Calculating QC Statistics This reference panel doesn't support chromosome 1. File ./1.TOPMED1KG.sites.gz not found.

Reference Panel: multiethnic-hla-panel-4digit (hg19)
Task 'Calculating QC Statistics This reference panel doesn't support chromosome 1. File ./1.TOPMED1KG.4digit.sites.gz not found.
```


These 3 panels fail.

```BASH
#impute_hla.bash -b hg19 -n 20250923-${b} -r multiethnic-hla-panel prep-${b}-1000g/${b}-updated-chr6.vcf.gz | sh
#	multiethnic-hla-panel
#	Error: More than 100 allele switches have been detected. Imputation cannot be started!

#impute_hla.bash -b hg19 -n 20250923-Ggroup-${b} -r multiethnic-hla-panel-Ggroup prep-${b}-1000g/${b}-updated-chr6.vcf.gz | sh
#	multiethnic-hla-panel-Ggroup
#	(Silent, no output at all)

#impute_hla.bash -b hg19 -n 20250923-4digit-${b} -r multiethnic-hla-panel-4digit prep-${b}-1000g/${b}-updated-chr6.vcf.gz | sh
#	multiethnic-hla-panel-4digit (synonomous with multiethnic-hla-panel?)
#	Error: More than 100 allele switches have been detected. Imputation cannot be started!
```


This is the only one that currently works for onco, i370, ????

```BASH
for b in onco i370 cidr tcga ; do
impute_hla.bash -b hg19 -n 20250923-4digit-v2-${b} -r multiethnic-hla-panel-4digit-v2 prep-${b}-1000g/${b}-updated-chr6.vcf.gz | sh
done
```



```BASH
mkdir hla-onco-hg19
cd hla-onco-hg19
curl -sL https://imputationserver.sph.umich.edu/get/1aHrKaTLbh8mWpGRmmLejmhVCFfjrfKW8AO9iQQn | bash
chmod -w *
cd ..

mkdir hla-i370-hg19
cd hla-i370-hg19
curl -sL https://imputationserver.sph.umich.edu/get/gUxz7jTdMNyMyMPxaIzmpXapyhgGH6qML50cIOkC | bash
chmod -w *
cd ..

mkdir hla-cidr-hg19
cd hla-cidr-hg19
curl -sL https://imputationserver.sph.umich.edu/get/sRJX2FbbwlpXjmCWMoM4niyAbDcMt0Amcgvicunl | bash
chmod -w *
cd ..

mkdir hla-tcga-hg19
cd hla-tcga-hg19
curl -sL https://imputationserver.sph.umich.edu/get/jkzYfdpjCjdGJM1n60oy05yzhLGiFs9Sx2jWkaxf | bash
chmod -w *
cd ..
```



```BASH
for b in onco i370 tcga cidr ; do
  echo ${b}
  cd hla-${b}-hg19
  chmod a-w *
  for zip in chr*zip ; do
    echo $zip
    unzip -P $( cat ../password-${b} ) $zip
  done
  chmod 440 *gz
  cd ..
done
```


Are these coordinates hg19 or hg38?


Assuming hg19 or hg38 as no data available for hg18

```BASH
for vcf in hla-*-hg19/chr6.info.gz ; do
echo $vcf
zgrep "^6" $vcf | awk 'BEGIN{OFS=":"}{print $1,$2,$3}' | sort > $(dirname $vcf)/rsids
zgrep "^6" $vcf | awk 'BEGIN{OFS=":"}{print $1,1+$2,$3}' | sort > $(dirname $vcf)/plusonersids

join $(dirname $vcf)/plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/common_rsids > $( dirname $vcf)/hg19_common_plusonersids
join $(dirname $vcf)/plusonersids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_rsids > $( dirname $vcf)/hg38_common_plusonersids
join $(dirname $vcf)/rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh37p13/VCF/common_rsids > $( dirname $vcf)/hg19_common_rsids
join $(dirname $vcf)/rsids /francislab/data1/refs/sources/ftp.ncbi.nih.gov/snp/organisms/human_9606_b151_GRCh38p7/VCF/common_rsids > $( dirname $vcf)/hg38_common_rsids
done


wc -l /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-*/*ids
```

Looks like these are standard hg19


Covert vcf to bim/bed/fam if needed.
```BASH
for vcf in hla-*-hg19/*.dose.vcf.gz ; do
echo $vcf
sbatch --job-name=$(dirname $vcf) --time=1 --ntasks=4 --mem=30G --output=${vcf}.makebed.${date}.txt \
--export=NONE --wrap="module load plink; plink --make-bed --vcf ${vcf} --out ${vcf%%.vcf.gz}"
done
```


HLA types are included in the VCFs just like a SNP.

```BASH
zcat hla-*-hg19/*.dose.vcf.gz | grep HLA
```




```BASH
for vcf in hla-*/chr6.dose.vcf.gz ; do
 echo $vcf
 zcat $vcf | awk 'BEGIN{FS=OFS="\t"}
  ($1~/^#CHROM/){gsub("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT","NAME\tAF\tR2",$0);print $0}
  ($3~/^HLA/){
   split($8,a,";");
   for(i in a){split(a[i],b,"=");if(b[1]=="AF")AF=b[2];if(b[1]=="R2")R2=b[2]}
   split($9,a,":");
   for(i in a){if(a[i]=="GT")GTP=i}
   out=$3"\t"AF"\t"R2;
   for(i=10;i<=NF;i++){split($i,a,":");out=out"\t"a[GTP]};
   print out}' > ${vcf%.dose.vcf.gz}.hla_genotype.csv
done

for vcf in hla-*/chr6.dose.vcf.gz ; do
 echo $vcf
 zcat $vcf | awk 'BEGIN{FS=OFS="\t"}
  ($1~/^#CHROM/){gsub("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT","NAME\tAF\tR2",$0);print $0}
  ($3~/^HLA/){
   split($8,a,";");
   for(i in a){split(a[i],b,"=");if(b[1]=="AF")AF=b[2];if(b[1]=="R2")R2=b[2]}
   split($9,a,":");
   for(i in a){if(a[i]=="DS")DSP=i}
   out=$3"\t"AF"\t"R2;
   for(i=10;i<=NF;i++){split($i,a,":");out=out"\t"a[DSP]};
   print out}' > ${vcf%.dose.vcf.gz}.hla_dosage.csv
done
```


```BASH
cat hla-*/*csv | awk '{print NF}' | uniq -c
    571 485
    571 4622
    571 4368
    571 6719
```

```BASH
for csv in  hla-*-hg19/*csv ; do
python3 -c "import pandas as pd;df=pd.read_csv('"${csv}"',header=0,index_col=[0,1,2],sep='\t');row_value_counts=df.apply(lambda row: row.value_counts(), axis=1).fillna(0);row_value_counts.div(len(df.columns),axis=0).to_csv('"${csv%.csv}.freqs.csv"')"
done
```

AF/MAF is 1/2 of the average dosage. (ALLELE frequency NOT SAMPLE frequency)
```BASH
for csv in hla-*-hg19/*dosage.csv ; do
python3 -c "import pandas as pd;df=pd.read_csv('"${csv}"',header=0,index_col=[0,1,2],sep='\t');means=df.mean(axis='columns').div(2,axis=0);print(means)"
done
```


Sums are all about 32 which would correspond to 16 different HLAs. Correct?
```BASH
for csv in hla-*-hg19/*dosage.csv ; do
python3 -c "import pandas as pd;df=pd.read_csv('"${csv}"',header=0,index_col=[0,1,2],sep='\t');print(df.sum(axis='index'))"
done
```


Add source column and join all four.
Would need to drop the AF and R2 columns, or rename them.







##	20251002

```BASH
\grep --no-filename -E -o 'AGS[[:digit:]]{5,}' /francislab/data1/raw/*-Illumina-PhIP/manifest.csv | sort | uniq > AGS_samples_in_PhIPseq

\grep --no-filename -E -o 'AGS[[:digit:]]{5,}' hla-*/*fam | sort | uniq > AGS_samples_in_Imputation

join AGS_samples_in_* > AGS_samples_in_both


wc -l AGS_samples_in_*
 2607 AGS_samples_in_Imputation
  126 AGS_samples_in_PhIPseq
   78 AGS_samples_in_both
```


```BASH
for s in dosage genotype ; do

paste <( cut -f1,3 hla-onco-hg19/chr6.hla_${s}.csv ) <( cut -f3 hla-i370-hg19/chr6.hla_${s}.csv ) | awk '(NR>1 && $2 >= 0.8 && $3 >= 0.8){print $1}' | sort | sed '1iNAME' > chr6.hla_${s}.onco_i370_gte_0.8.csv

head -1 hla-onco-hg19/chr6.hla_${s}.csv > hla-onco-hg19/chr6.hla_${s}.sorted.csv
tail -n +2 hla-onco-hg19/chr6.hla_${s}.csv | sort -t $'\t' -k1,1 >> hla-onco-hg19/chr6.hla_${s}.sorted.csv
join --header -t $'\t' chr6.hla_${s}.onco_i370_gte_0.8.csv hla-onco-hg19/chr6.hla_${s}.sorted.csv | datamash transpose -t $'\t' > tmp
head -1 tmp > hla-onco-hg19/chr6.hla_${s}.t.agsonly.csv
#sed -i '1s/^/NAME\t/' hla-onco-hg19/chr6.hla_${s}.t.agsonly.csv
tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-onco-hg19/chr6.hla_${s}.t.csv
awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_${s}.t.csv > hla-onco-hg19/chr6.hla_${s}.t.ags_ids.csv
join -t $'\t' hla-onco-hg19/chr6.hla_${s}.t.ags_ids.csv hla-onco-hg19/chr6.hla_${s}.t.csv | cut -d $'\t' -f2- >> hla-onco-hg19/chr6.hla_${s}.t.agsonly.csv

head -1 hla-i370-hg19/chr6.hla_${s}.csv > hla-i370-hg19/chr6.hla_${s}.sorted.csv
tail -n +2 hla-i370-hg19/chr6.hla_${s}.csv | sort -t $'\t' -k1,1 >> hla-i370-hg19/chr6.hla_${s}.sorted.csv
join --header -t $'\t' chr6.hla_${s}.onco_i370_gte_0.8.csv hla-i370-hg19/chr6.hla_${s}.sorted.csv | datamash transpose -t $'\t' > tmp
head -1 tmp > hla-i370-hg19/chr6.hla_${s}.t.agsonly.csv
#sed -i '1s/^/NAME\t/' hla-i370-hg19/chr6.hla_${s}.t.agsonly.csv
tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-i370-hg19/chr6.hla_${s}.t.csv
awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_${s}.t.csv > hla-i370-hg19/chr6.hla_${s}.t.ags_ids.csv
join -t $'\t' hla-i370-hg19/chr6.hla_${s}.t.ags_ids.csv hla-i370-hg19/chr6.hla_${s}.t.csv | cut -d $'\t' -f2- >> hla-i370-hg19/chr6.hla_${s}.t.agsonly.csv

done


#cat hla-onco-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-onco-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_dosage.t.csv > hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv
#join -t $'\t' hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv hla-onco-hg19/chr6.hla_dosage.t.csv >> hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#
#cat hla-i370-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-i370-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_dosage.t.csv > hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv
#join -t $'\t' hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv hla-i370-hg19/chr6.hla_dosage.t.csv >> hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#
#cat hla-onco-hg19/chr6.hla_genotype.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-onco-hg19/chr6.hla_genotype.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-onco-hg19/chr6.hla_genotype.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_genotype.t.csv > hla-onco-hg19/chr6.hla_genotype.t.ags_ids.csv
#join -t $'\t' hla-onco-hg19/chr6.hla_genotype.t.ags_ids.csv hla-onco-hg19/chr6.hla_genotype.t.csv | cut -d $'\t' -f2- >> hla-onco-hg19/chr6.hla_genotype.t.agsonly.csv
#
#cat hla-i370-hg19/chr6.hla_genotype.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-i370-hg19/chr6.hla_genotype.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-i370-hg19/chr6.hla_genotype.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_genotype.t.csv > hla-i370-hg19/chr6.hla_genotype.t.ags_ids.csv
#join -t $'\t' hla-i370-hg19/chr6.hla_genotype.t.ags_ids.csv hla-i370-hg19/chr6.hla_genotype.t.csv | cut -d $'\t' -f2- >> hla-i370-hg19/chr6.hla_genotype.t.agsonly.csv







#cat hla-onco-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-onco-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_dosage.t.csv > hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv
#join -t $'\t' hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv hla-onco-hg19/chr6.hla_dosage.t.csv >> hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#
#cat hla-i370-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-i370-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_dosage.t.csv > hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv
#join -t $'\t' hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv hla-i370-hg19/chr6.hla_dosage.t.csv >> hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#
#cat hla-onco-hg19/chr6.hla_genotype.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-onco-hg19/chr6.hla_genotype.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-onco-hg19/chr6.hla_genotype.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_genotype.t.csv > hla-onco-hg19/chr6.hla_genotype.t.ags_ids.csv
#join -t $'\t' hla-onco-hg19/chr6.hla_genotype.t.ags_ids.csv hla-onco-hg19/chr6.hla_genotype.t.csv | cut -d $'\t' -f2- >> hla-onco-hg19/chr6.hla_genotype.t.agsonly.csv
#
#cat hla-i370-hg19/chr6.hla_genotype.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-i370-hg19/chr6.hla_genotype.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-i370-hg19/chr6.hla_genotype.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_genotype.t.csv > hla-i370-hg19/chr6.hla_genotype.t.ags_ids.csv
#join -t $'\t' hla-i370-hg19/chr6.hla_genotype.t.ags_ids.csv hla-i370-hg19/chr6.hla_genotype.t.csv | cut -d $'\t' -f2- >> hla-i370-hg19/chr6.hla_genotype.t.agsonly.csv





#cat hla-onco-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-onco-hg19/chr6.hla_dosage.t.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 >> hla-onco-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR<=3){print $1,"AGS"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_dosage.t.csv > hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv
#join --header -t $'\t' hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv hla-onco-hg19/chr6.hla_dosage.t.csv > hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#
#cat hla-i370-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-i370-hg19/chr6.hla_dosage.t.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 >> hla-i370-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR<=3){print $1,"AGS"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_dosage.t.csv > hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv
#
#cat hla-onco-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-onco-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_dosage.t.csv > hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv
#join -t $'\t' hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv hla-onco-hg19/chr6.hla_dosage.t.csv >> hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#
#cat hla-i370-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-i370-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_dosage.t.csv > hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv
#join -t $'\t' hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv hla-i370-hg19/chr6.hla_dosage.t.csv >> hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#
#cat hla-onco-hg19/chr6.hla_genotype.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-onco-hg19/chr6.hla_genotype.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-onco-hg19/chr6.hla_genotype.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_genotype.t.csv > hla-onco-hg19/chr6.hla_genotype.t.ags_ids.csv
#join -t $'\t' hla-onco-hg19/chr6.hla_genotype.t.ags_ids.csv hla-onco-hg19/chr6.hla_genotype.t.csv | cut -d $'\t' -f2- >> hla-onco-hg19/chr6.hla_genotype.t.agsonly.csv
#
#cat hla-i370-hg19/chr6.hla_genotype.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-i370-hg19/chr6.hla_genotype.t.agsonly.csv
#sed -i '1,3s/^/\t/' hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 > hla-i370-hg19/chr6.hla_genotype.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_genotype.t.csv > hla-i370-hg19/chr6.hla_genotype.t.ags_ids.csv
#join -t $'\t' hla-i370-hg19/chr6.hla_genotype.t.ags_ids.csv hla-i370-hg19/chr6.hla_genotype.t.csv | cut -d $'\t' -f2- >> hla-i370-hg19/chr6.hla_genotype.t.agsonly.csv
#
#
#
#cat hla-onco-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-onco-hg19/chr6.hla_dosage.t.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 >> hla-onco-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR<=3){print $1,"AGS"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_dosage.t.csv > hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv
#join --header -t $'\t' hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv hla-onco-hg19/chr6.hla_dosage.t.csv > hla-onco-hg19/chr6.hla_dosage.t.agsonly.csv
#
#cat hla-i370-hg19/chr6.hla_dosage.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-i370-hg19/chr6.hla_dosage.t.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 >> hla-i370-hg19/chr6.hla_dosage.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR<=3){print $1,"AGS"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_dosage.t.csv > hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv
#join --header -t $'\t' hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv hla-i370-hg19/chr6.hla_dosage.t.csv > hla-i370-hg19/chr6.hla_dosage.t.agsonly.csv
#
#cat hla-onco-hg19/chr6.hla_genotype.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-onco-hg19/chr6.hla_genotype.t.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 >> hla-onco-hg19/chr6.hla_genotype.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR<=3){print $1,"AGS"}(NR>3 && $1~/AGS/){split($1,a,"-");print $1,a[3]}' hla-onco-hg19/chr6.hla_genotype.t.csv > hla-onco-hg19/chr6.hla_genotype.t.ags_ids.csv
#join --header -t $'\t' hla-onco-hg19/chr6.hla_genotype.t.ags_ids.csv hla-onco-hg19/chr6.hla_genotype.t.csv | cut -d $'\t' -f2- > hla-onco-hg19/chr6.hla_genotype.t.agsonly.csv
#
#cat hla-i370-hg19/chr6.hla_genotype.csv | datamash transpose -t $'\t' > tmp
#head -3 tmp > hla-i370-hg19/chr6.hla_genotype.t.csv
#tail -n +4 tmp | sort -t $'\t' -k1,1 >> hla-i370-hg19/chr6.hla_genotype.t.csv
#awk 'BEGIN{FS=OFS="\t"}(NR<=3){print $1,"AGS"}(NR>3 && $1~/AGS/){split($1,a,"_");print $1,a[1]}' hla-i370-hg19/chr6.hla_genotype.t.csv > hla-i370-hg19/chr6.hla_genotype.t.ags_ids.csv
#join --header -t $'\t' hla-i370-hg19/chr6.hla_genotype.t.ags_ids.csv hla-i370-hg19/chr6.hla_genotype.t.csv | cut -d $'\t' -f2- > hla-i370-hg19/chr6.hla_genotype.t.agsonly.csv
```


```r
library(tidyr)
library(dplyr)

df=read.csv("hla-onco-hg19/chr6.hla_genotype.t.agsonly.csv", sep="\t", header=TRUE)
colnames(df)=sub('\\.','-',colnames(df))
two = df[,!grepl("\\.", colnames(df))]

#hlaa_cols=c('AGS',colnames(two)[grepl("HLA_A",colnames(two))])
#hlaa=two[,hlaa_cols]
#hlaa[0:5,0:5]
#t=pivot_longer(hlaa,cols=colnames(hlaa)[grepl("HLA_A",colnames(hlaa))])
#t=t[t$value != "0|0",]
#t=rbind(t,t[t$value == "1|1",])
#t=separate(t, col = name, into = c("locus", "twodigit"), sep = "-")
#t=arrange(t,AGS)
#t=select(t,-value)
#t=pivot_wider(t,names_from=locus,values_from=twodigit)
#t=unnest_wider(t,HLA_A,names_sep='-a')

#	extra allele HLA_DQA1-a3 caused by ...
#	AGS48257 HLA_DQA1
#> two[two$AGS == 'AGS48257',colnames(two)[grepl('HLA_DQA1',colnames(two))]]
#    HLA_DQA1-01 HLA_DQA1-02 HLA_DQA1-03 HLA_DQA1-04 HLA_DQA1-05 HLA_DQA1-06
#642         1|1         0|0         0|1         0|0         0|0         0|0
#	dosage ... both "round up"
#> two[two$AGS == 'AGS48257',colnames(two)[grepl('HLA_DQA1',colnames(two))]]
#    HLA_DQA1-01 HLA_DQA1-02 HLA_DQA1-03 HLA_DQA1-04 HLA_DQA1-05 HLA_DQA1-06
#642         1.5           0         0.5           0           0           0

#	several NAs in matrix caused by dispered dosages
#	AGS41351 HLA_DRB1
#> two[two$AGS == 'AGS41351',colnames(two)[grepl('HLA_DRB1',colnames(two))]]
#> two[two$AGS == 'AGS41351',colnames(two)[grepl('HLA_DRB1',colnames(two))]]
#    HLA_DRB1-01 HLA_DRB1-03 HLA_DRB1-04 HLA_DRB1-07 HLA_DRB1-08 HLA_DRB1-09
#352         0|0         0|1         0|0         0|0         0|0         0|0
#    HLA_DRB1-10 HLA_DRB1-11 HLA_DRB1-12 HLA_DRB1-13 HLA_DRB1-14 HLA_DRB1-15
#352         0|0         0|0         0|0         0|0         0|0         0|0
#    HLA_DRB1-16
#352         0|0
#> two[two$AGS == 'AGS41351',colnames(two)[grepl('HLA_DRB1',colnames(two))]]
#    HLA_DRB1-01 HLA_DRB1-03 HLA_DRB1-04 HLA_DRB1-07 HLA_DRB1-08 HLA_DRB1-09
#352       0.009       1.467           0           0       0.018           0
#    HLA_DRB1-10 HLA_DRB1-11 HLA_DRB1-12 HLA_DRB1-13 HLA_DRB1-14 HLA_DRB1-15
#352           0       0.494       0.003       0.003       0.002           0
#    HLA_DRB1-16
#352           0



t=pivot_longer(two,cols=colnames(two)[grepl("HLA_",colnames(two))])
t=t[t$value != "0|0",]
t=rbind(t,t[t$value == "1|1",])
t=separate(t, col = name, into = c("locus", "twodigit"), sep = "-")
t=arrange(t,AGS,locus)
t=select(t,-value)
t=pivot_wider(t,names_from=locus,values_from=twodigit)
t=unnest_wider(t,colnames(t)[grepl("HLA_",colnames(t))],names_sep='-a')

write.csv(t, "my_data_base.csv", row.names = FALSE, quote=FALSE)


```


```BASH
wc -l /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/AGS*
 3508 AGS_calls.csv
  249 AGS.csv
  253 AGS_manifest.csv
```

```BASH
head -1 AGS*
==> AGS_calls.csv <==
AGSID,CMV,EBV,HSV,XVZV2

==> AGS.csv <==
UCSFid,AGSid,age,sex,plate,CMV,EBV,HSV,XVZV2

==> AGS_manifest.csv <==
AGSid,UCSFid,age,sex,plate
```




##	20251006


```BASH
head /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/AGS_manifest.csv 

AGSid,UCSFid,age,sex,plate

Not sure if UCSFid is needed
Add the dataset column to this manifest and keep the dosages by themselves.

#cut -d, -f1,3,4,5 /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/AGS_manifest.csv | uniq > ags_manifest.csv
cat /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/AGS_manifest.csv | uniq > ags_manifest.csv
```


```BASH
awk '{print $2",onco"}' hla-onco-hg19/chr6.hla_dosage.t.ags_ids.csv > tmp.csv
awk '{print $2",i370"}' hla-i370-hg19/chr6.hla_dosage.t.ags_ids.csv >> tmp.csv
sort -k1,1 -t, tmp.csv | sed '1iid,dataset' > ags_datasets.csv

join --header -t, ags_manifest.csv ags_datasets.csv > ags_covars.csv
```


```BASH
s=dosage
paste <( cut -f1,3 hla-onco-hg19/chr6.hla_${s}.csv ) <( cut -f3 hla-i370-hg19/chr6.hla_${s}.csv ) | awk '(NR>1 && $2 >= 0.8 && $3 >= 0.8){print $1}' | sort | sed '1iNAME' > chr6.hla_${s}.onco_i370_gte_0.8.csv

for d in i370 onco ; do
head -1 hla-${d}-hg19/chr6.hla_${s}.csv > tmp1.csv
tail -n +2 hla-${d}-hg19/chr6.hla_${s}.csv | sort -t $'\t' -k1,1 >> tmp1.csv
join --header -t $'\t' chr6.hla_${s}.onco_i370_gte_0.8.csv tmp1.csv > hla-${d}-hg19/chr6.hla_${s}.gte_0.8.csv
cat hla-${d}-hg19/chr6.hla_${s}.gte_0.8.csv | datamash transpose -t $'\t' > hla-${d}-hg19/chr6.hla_${s}.gte_0.8.t.csv
head -1 hla-${d}-hg19/chr6.hla_${s}.gte_0.8.t.csv > tmp4.csv
tail -n +4 hla-${d}-hg19/chr6.hla_${s}.gte_0.8.t.csv | sort -t $'\t' -k1,1 >> tmp4.csv
join --header -t $'\t' <( sed '1iplink\tid' hla-${d}-hg19/chr6.hla_${s}.t.ags_ids.csv ) tmp4.csv | cut -d $'\t' -f2- > hla-${d}-hg19/chr6.hla_${s}.gte_0.8.t.agsonly.csv
done
\rm tmp*.csv
```


```BASH
head -1 hla-onco-hg19/chr6.hla_dosage.gte_0.8.t.agsonly.csv > tmp1.csv
tail -q -n +2 hla-*-hg19/chr6.hla_dosage.gte_0.8.t.agsonly.csv | sort -t $'\t' -k1,1 >> tmp1.csv

join --header -t $'\t' <( cat ags_covars.csv | tr , '\t' ) tmp1.csv | tr '\t' , > chr6.hla_dosage.onco_i370_gte_0.8.t.agsonly.select.csv
\rm tmp*.csv
```



Now get the peptide tile q40 counts for just the ags ids.
Join with the raw ags_manifest.csv
head /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/AGS_manifest.csv 


```BASH
cat /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/out.123456131415161718/AllActualSamples.csv | datamash transpose -t, > tmp1.csv
head -1 tmp1.csv > tmp2.csv
tail -n +3 tmp1.csv | sort -t, -k1,1 >> tmp2.csv

awk 'BEGIN{FS=OFS=","}{print $2,$1}' /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/AGS_manifest.csv > tmp3.csv
head -1 tmp3.csv > tmp4.csv
tail -n +2 tmp3.csv | sort -t, -k1,1 >> tmp4.csv

join --header -t, tmp4.csv tmp2.csv | awk 'BEGIN{FS=OFS=","}{x=$1;$1=$2;$2=x;print}' > tmp5.csv

head -1 tmp5.csv > tmp6.csv
tail -n +2 tmp5.csv | sort -t, -k1,1 >> tmp6.csv

join --header -t, <( cut -d, -f1 ags_covars.csv | uniq ) tmp6.csv | cut -d, -f2- > tmp7.csv

head -1 tmp7.csv > ags_sample_tile_q40_counts.csv
tail -n +2 tmp7.csv | sort -t, -k1,1 >> ags_sample_tile_q40_counts.csv

\rm tmp*.csv
```



##	20251007



```BASH
head -1 hla-onco-hg19/chr6.hla_dosage.gte_0.8.t.agsonly.csv > chr6.hla_dosage.gte_0.8.t.agsonly.csv
tail -q -n +2 hla-*-hg19/chr6.hla_dosage.gte_0.8.t.agsonly.csv | sort -t $'\t' -k1,1 >> chr6.hla_dosage.gte_0.8.t.agsonly.csv
sed -i 's/\t/,/g' chr6.hla_dosage.gte_0.8.t.agsonly.csv
```


```BASH
cat ags_sample_tile_q40_counts.csv | datamash transpose -t, > tmp1.csv

head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k1,1 >> tmp2.csv

join --header -t, /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_species.uniq.csv tmp2.csv > tmp3.csv

cat tmp3.csv | datamash transpose -t, > ags_sample_tile_q40_counts.species.csv

join --header -t, <( cut -d, -f1 ags_covars.csv ) chr6.hla_dosage.onco_i370_gte_0.8.t.agsonly.csv | uniq > chr6.hla_dosage.onco_i370_gte_0.8.t.agsonly.select.csv


join --header -t, ags_covars.csv chr6.hla_dosage.onco_i370_gte_0.8.t.agsonly.select.csv > tmp1.csv

head -1 tmp1.csv > tmp2.csv
tail -n +2 tmp1.csv | sort -t, -k2,2 >> tmp2.csv


head -1 ags_sample_tile_q40_counts.species.csv > tmp3.csv
join --header -t, -1 2 -2 1 tmp2.csv <( tail -n +2 ags_sample_tile_q40_counts.species.csv ) >> tmp3.csv
for i in $(seq 1 308); do sed -i '1s/^/,/' tmp3.csv ; done

mv tmp3.csv ags_hla_sample_tile_q40_counts.species.csv

```

