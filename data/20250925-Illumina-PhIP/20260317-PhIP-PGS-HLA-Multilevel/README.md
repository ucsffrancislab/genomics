
#	20250925-Illumina-PhIP/20260317-PhIP-PGS-HLA-Multilevel


Using Claude to develop an Edison prompt

https://claude.ai/chat/d4e71001-213c-42b0-b453-73916453c329

to develop a crossover pipeline for Glioma Case/Control

using PhIPseq, PGS and HLA data.


```bash

cp ../20260218-PhIP-MultiPlate-Multilevel/vir3_taxonomic_annotation_database_complete.csv.gz ./
cp ../20260218-PhIP-MultiPlate-Multilevel/Zscores.csv.gz ./

```


Build metadata files to check.

`PhIPseq_sample_mapping.csv`

```bash
sample,subject,plate,type

```

```bash
awk 'BEGIN{FS=OFS=","}(NR==1 || ( ( $3 == "glioma serum" ) || ( $3 == "input" ) || ( $3 == "Phage Library" ) || ( $3 == "commercial serum control" ) ) && ($8 >= 1 && $8<=6) ){print $1,$2,$8,$3}' ../20260218-PhIP-MultiPlate-Multilevel/manifest.csv > PhIPseq_sample_mapping.csv

sed -i 's/glioma serum/experimental/g' PhIPseq_sample_mapping.csv
sed -i 's/commercial serum control/commercial/g' PhIPseq_sample_mapping.csv
sed -i 's/Phage Library/library/g' PhIPseq_sample_mapping.csv
sed -i 's/input/blank/g' PhIPseq_sample_mapping.csv

```



`metadata.csv`

```bash
subject,IID,dataset,age,sex,case,grade,idh,pq,rad,chemo,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,survdays,vstatus

```


```bash
head -1 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_lasso_survival_analysis/cidr-covariates.csv > covariates.csv
tail -q -n +2 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_lasso_survival_analysis/*-covariates.csv | sort -t, -k1,1 >> covariates.csv
```

Need to create a UCSFid to IID map.

```bash
awk 'BEGIN{FS=OFS=","}(NR>1 && (($6=="AGS") || ($6=="IPS"))){if($6=="IPS"){$8=substr($2,1,5)}gsub(/dup/,"",$2);print $8,$2}' /francislab/data1/raw/20241204-Illumina-PhIP/L1_full_covariatesv2_Vir3_phip-seq_GBM_p1_MENPEN_p13_12-6-24hmh.csv > tmp1.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && (($8=="AGS") || ($8=="IPS"))){if($8=="IPS"){$10=substr($3,1,5)}gsub(/dup/,"",$3);print $10,$3}' /francislab/data1/raw/20241224-Illumina-PhIP/L2_full_covariates_Vir3_phip-seq_GBM_p2_MENPEN_p14_12-29-24hmh_L2_Covar.csv >> tmp1.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && (($8=="AGS") || ($8=="IPS"))){if($8=="IPS"){$10=substr($3,1,5)}gsub(/dup/,"",$3);print $10,$3}' /francislab/data1/raw/20250128-Illumina-PhIP/L3_full_covariates_Vir3_phip-seq_GBM_p3_and_p4_1-28-25hmh.csv >> tmp1.csv
awk 'BEGIN{FS=OFS=","}(NR>1 && (($8=="AGS") || ($8=="IPS"))){if($8=="IPS"){$10=substr($3,1,5)}gsub(/dup/,"",$3);print $10,$3}' /francislab/data1/raw/20250409-Illumina-PhIP/L4_full_covariates_Vir3_phip-seq_GBM_p5_and_p6_4-10-25hmh.csv >> tmp1.csv

sort tmp1.csv | uniq > AGSIPS_UCSFid.csv
\rm tmp1.csv



awk 'BEGIN{FS=OFS=","}($3=="IPS"){ split($1,a,"_");split(a[2],b,"-"); print $1,b[1]}' covariates.csv > CIDRIID_gID.csv


#join -t, <( tail -n +2 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/CIDR_gIPS.csv) <( tail -n +2 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/CIDR_IPS.csv | sort -t, -k1 ) | awk 'BEGIN{FS=OFS=","}{ print $3,substr($2,2,3)"_"$2}' > IPS_CIDRIID.csv
#	that's wrong


join -t, -1 2 -2 1 <( sort -t, -k2,2 CIDRIID_gID.csv ) <( tail -n +2 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/CIDR_IPS.csv | sort -t, -k1,1 ) | awk 'BEGIN{FS=OFS=","}{print $3,$2}' > IPS_CIDRIID.csv













tail -n +2 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/I370_AGS.csv | awk 'BEGIN{FS=OFS=","}{print $1,$2"_"$2}' > AGS_I370IID.csv
tail -n +2 /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/ONCO_AGS.csv | awk 'BEGIN{FS=OFS=","}{print $1,"0_"$2}' > AGS_ONCOIID.csv

cat AGS_I370IID.csv AGS_ONCOIID.csv | sort -t, -k2,2 > AGS_IID.csv


join -t, <( sort -t, -k1,1 IPS_CIDRIID.csv ) <( sort -t, -k1,1 AGSIPS_UCSFid.csv ) > IPS_CIDRIID_UCSFid.csv

join -t, <( sort -t, -k1,1 AGS_IID.csv ) <( sort -t, -k1,1 AGSIPS_UCSFid.csv ) > AGS_IID_UCSFid.csv

cat IPS_CIDRIID_UCSFid.csv AGS_IID_UCSFid.csv | awk 'BEGIN{FS=OFS=","}{print $3,$2}' | sort -t, -k1,1 > UCSFid_IID.csv
sed -i '1isubject,IID' UCSFid_IID.csv

cat IPS_CIDRIID_UCSFid.csv AGS_IID_UCSFid.csv | awk 'BEGIN{FS=OFS=","}{print $2,$3}' | sort -t, -k1,1 > IID_UCSFid.csv
sed -i '1iIID,subject' IID_UCSFid.csv

join --header -t, IID_UCSFid.csv covariates.csv | cut -d, -f1-10,12-23 > IID_covariates.csv

```

no covariates for AGS50742 / 4582






This is the AGS / IPS id
Need it to be either the IID or the subject

```bash

join --header -t, <( sed 1iAGSIPS,subject AGSIPS_UCSFid.csv ) <( cut -d, -f1,6- /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/chr6.hla_dosage.onco_i370_cidr_gte_0.8.t.agsipsonly.select.csv ) | cut -d, -f2- > subject_HLA_dosages.csv

```






MERGE PGS scores

/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_lasso_survival_analysis/cidr.scores.z-scores.txt.gz











Send final prompt to Edison.

```bash

```
