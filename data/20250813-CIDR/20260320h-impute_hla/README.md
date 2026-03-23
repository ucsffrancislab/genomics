
#	20250813-CIDR/20260320h-impute_hla



```bash
mkdir work
cd work
ln -s /francislab/data1/working/20250813-CIDR/20260320e-prep_for_imputation/work/cidr-updated-chr6.vcf.gz
cd ..

```


Will need to create a UMICH TOKEN from your account. 
Put it in the file called UMICH_TOKEN.
Write protect it.

```bash
#vi UMICH_TOKEN
#chmod 400 UMICH_TOKEN

ln -s /francislab/data1/working/20250813-CIDR/20260320f-impute_genotypes/UMICH_TOKEN
```


##	Impute for all 4 datasets


```bash
impute_hla.bash -b hg19 -n 20260320-4digit-v2-cidr -r multiethnic-hla-panel-4digit-v2 work/cidr-updated-chr6.vcf.gz | sh

```

##	Download

```bash
mkdir hla-cidr-hg19
cd hla-cidr-hg19
curl -sL https://imputationserver.sph.umich.edu/get/WJBLzVpb0X63U803F8JQW2SdGwIsaUuugZbSXRbe | bash
chmod -w *
cd ..
```

##	Unzip

```bash
cd hla-cidr-hg19
chmod a-w *
for zip in chr*zip ; do
  echo $zip
  unzip -P $( cat ../password ) $zip
done
chmod 440 *gz
cd ..
```

