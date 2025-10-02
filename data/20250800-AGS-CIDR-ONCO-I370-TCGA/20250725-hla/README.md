
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



