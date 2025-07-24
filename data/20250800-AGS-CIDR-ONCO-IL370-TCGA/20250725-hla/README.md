
#	20250800-AGS-CIDR-ONCO-IL370-TCGA/20250725-hla



Use the prep from ../20250723-survival_gwas and ../20250724-pgs


```
ln -s ../20250724-pgs/prep-onco
ln -s ../20250724-pgs/prep-il370
ln -s ../20250724-pgs/prep-cidr
ln -s ../20250724-pgs/prep-tcga
```


##  Impute HLA for all 4 datasets


```
for b in onco il370 cidr tcga ; do
impute_hla.bash -b hg19 -n 20250728-Ggroup-${b} -r multiethnic-hla-panel-Ggroup prep-${b}/${b}-updated-chr*.vcf.gz
impute_hla.bash -b hg19 -n 20250728-4digit-${b} -r multiethnic-hla-panel-4digit prep-${b}/${b}-updated-chr*.vcf.gz
done
```



