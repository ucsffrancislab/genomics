
#	20250813-CIDR/20260320f-impute_genotypes


```bash
mkdir work
cd work
for vcf in /francislab/data1/working/20250813-CIDR/20260320e-prep_for_imputation/work/*vcf.gz ; do
ln -s $vcf
done
cd ..

```


Will need to create a UMICH TOKEN from your account. 
Put it in the file called UMICH_TOKEN.
Write protect it.

```bash

vi UMICH_TOKEN
chmod 400 UMICH_TOKEN

```



UMich 1000g checked hg19

Population 'all' is not supported by reference panel '1000g-phase-3-v5'.

UMich only allows 2 jobs in the queue at a time.

-F "job-name=20251218-tcga-1kghg19" -F "refpanel=1000g-phase-3-v5" -F "build=hg19" -F "r2Filter=0.3" -F "phasing=eagle" -F "population=off"


```bash
impute_genotypes.bash --server umich --refpanel 1000g-phase-3-v5 --build hg19 \
 -n 20260320-cidr-1kghg19 work/cidr-updated-chr*.vcf.gz | sh
```














##	Download


```
mkdir imputed-umich-cidr
cd imputed-umich-cidr
curl -sL https://imputationserver.sph.umich.edu/get/5U96DvpQuD1MPZ5O1evdfzVo6hzzq797qqch6xC7 | bash
chmod -w *
cd ..
```




Create and chmod password files for umich and each dataset

```BASH
cd imputed-umich-cidr
chmod a-w *
for zip in chr*zip ; do
  echo $zip
  unzip -P $( cat ../password ) $zip
done
chmod 440 *gz
cd ..
```


reference ...  20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/README.md


