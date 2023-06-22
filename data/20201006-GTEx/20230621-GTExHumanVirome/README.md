

#	GTEx


From "A tissue level atlas of the healthy human virome"
https://bmcbiol.biomedcentral.com/articles/10.1186/s12915-020-00785-5

Additional file 2: Table S2. List of the 39 viral species detected in this study.
https://static-content.springer.com/esm/art%3A10.1186%2Fs12915-020-00785-5/MediaObjects/12915_2020_785_MOESM2_ESM.xlsx

Additional file 3: Table S3. Read count (from each of 8990 samples used) of the respective 39 viral species detected in this study.
https://static-content.springer.com/esm/art%3A10.1186%2Fs12915-020-00785-5/MediaObjects/12915_2020_785_MOESM3_ESM.xlsx

I don't see a direct link of viral counts to tissue types but I presume that this could be determined as each sample is from a specific tissue.

I have a file /francislab/data1/raw/20201006-GTEx/SraRunTable.txt that has 24455 samples


```
awk 'BEGIN{FS=OFS=","}{print $1,$11}' /francislab/data1/raw/20201006-GTEx/SraRunTable.txt  | head

Run,body_site
SRR8227334,Skin - Sun Exposed (Lower leg)
SRR8227335,Thyroid
SRR8227336,Testis
SRR8227337,Minor Salivary Gland
SRR8227338,Brain - Cerebellum
SRR8227339,Adipose - Subcutaneous
SRR8227340,Muscle - Skeletal
SRR8227341,Artery - Tibial
SRR8227342,Minor Salivary Gland
```



```
awk 'BEGIN{FS=OFS=","}($11~/^Brain/){print $1}' /francislab/data1/raw/20201006-GTEx/SraRunTable.txt | sort > Brain_SampleIDs

head -1 /francislab/data1/raw/20201006-GTEx/SraRunTable.txt > SraRunTable.sorted.txt
tail -n +2 /francislab/data1/raw/20201006-GTEx/SraRunTable.txt | sort -t, -k1,1 >> SraRunTable.sorted.txt
```

```
head -2 12915_2020_785_MOESM3_ESM\ -\ Table\ S3.csv | tail -1 | tr -d '\015' > Brain_S3.csv
grep -f Brain_SampleIDs 12915_2020_785_MOESM3_ESM\ -\ Table\ S3.csv | tr -d '\015' >> Brain_S3.csv


wc -l SraRunTable.txt 
24456 SraRunTable.txt

wc -l 12915_2020_785_MOESM3_ESM\ -\ Table\ S3.csv 
8992 12915_2020_785_MOESM3_ESM - Table S3.csv

wc -l Brain_S3.csv 
1385 Brain_S3.csv



join -t, --nocheck-order --header Brain_S3.csv SraRunTable.sorted.txt > Brain.csv

```




```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in Brain.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done


```




