
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

