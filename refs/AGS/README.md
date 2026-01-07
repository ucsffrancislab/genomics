
#	AGS


```bash

cp /francislab/data1/users/gguerra/20211112-Viral-Glioma-SES-study/Data/AGS_Covariates_Updated_2022-11-03.csv /francislab/data1/refs/AGS/

cp ~/github/ucsffrancislab/genomics/Geno/AGS_Ig_Analysis/Cleaned_Covariates_with_HLA.tsv ./

box_upload.bash AGS_Covariates_Updated_2022-11-03.csv

```


```bash

cut -d, -f27 AGS_Covariates_Updated_2022-11-03.csv | sort | uniq -c
    766 0
    932 1
      5 8
      1 CMV
   1805 NA

cut -d, -f28 AGS_Covariates_Updated_2022-11-03.csv | sort | uniq -c
    107 0
   1587 1
      4 8
      1 EBV
   1810 NA

cut -d, -f29 AGS_Covariates_Updated_2022-11-03.csv | sort | uniq -c
    448 0
   1243 1
      4 8
      1 HSV
   1813 NA

cut -d, -f30 AGS_Covariates_Updated_2022-11-03.csv | sort | uniq -c
    141 0
   2361 1
      7 2
      4 8
    995 NA
      1 XVZV2

cp /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/AGS.csv ./
cp /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/AGS_calls.csv ./
cp /francislab/data1/working/20250409-Illumina-PhIP/20250414-PhIP-MultiPlate/AGS_manifest.csv ./
box_upload.bash AGS.csv AGS_calls.csv AGS_manifest.csv

```



```bash

cut -d, -f6 AGS.csv | sort | uniq -c
     64 0
     52 1
      1 CMV
    132 NA

cut -d, -f7 AGS.csv | sort | uniq -c
      4 0
    112 1
      1 EBV
    132 NA

cut -d, -f8 AGS.csv | sort | uniq -c
     22 0
     92 1
      1 HSV
    134 NA

cut -d, -f9 AGS.csv | sort | uniq -c
    162 1
     86 NA
      1 XVZV2

```

