
#	20240918-MeningiomaGWAS


```

curl  --ftp-create-dirs -netrc "ftps://ftp.box.com/Francis _Lab_Share/meningioma GWAS dataset clean/MeningiomaSharedBinaryFiles.tar.gz" --output MeningiomaSharedBinaryFiles.tar.gz

curl  --ftp-create-dirs -netrc "ftps://ftp.box.com/Francis _Lab_Share/meningioma GWAS dataset clean/meningioma_id.txt" --output meningioma_id.txt


```




##	20250512


Difference between the bed/bim/fam and the provided CSV.

```
tail -n +2 MENCasesandControls.csv | wc -l

tail -n +2 MENCasesandControls.csv | awk -F, '{print substr($1,0,3)","$5}' | sort | uniq -c | awk '{print $2","$1}' | sed '1iprefix,sex,count'

tail -n +2 MENCasesandControls.csv | awk -F, '{print substr($1,0,3)","$6}' | sort | uniq -c | awk '{print $2","$1}' | sed '1iprefix,affected,count'

tail -n +2 MENCasesandControls.csv | awk -F, '{print substr($1,0,3)","$5","$6}' | sort | uniq -c | awk '{print $2","$1}' | sed '1iprefix,sex,affected,count'
```

The fam file contains

2300 samples which are simply numbers.

```
wc -l MENINGIOMA_GWAS_SHARED.fam
4231

tail -n +2301 MENINGIOMA_GWAS_SHARED.fam  | cut -c1-3 | sort | uniq -c
    198 FAM
     77 MEN
    421 pla
   1235 Pla

tail -n +2301 MENINGIOMA_GWAS_SHARED.fam  | wc -l
1931

tail -n +2499 MENINGIOMA_GWAS_SHARED.fam  | wc -l
1733

tail -n +2499 MENINGIOMA_GWAS_SHARED.fam  | awk '{print substr($1,0,3)","$5","$6}' | sort | uniq -c
     27 MEN,2,1
     50 MEN,2,2
     53 pla,1,1
    166 Pla,1,1
     81 pla,1,2
    187 Pla,1,2
    108 pla,2,1
    444 Pla,2,1
    179 pla,2,2
    438 Pla,2,2
```





Dump those not in the CSV?



