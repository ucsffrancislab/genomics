
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

chmod -w *
cd ..




mkdir hla-tcga-hg19
cd hla-tcga-hg19

chmod -w *
cd ..

```






