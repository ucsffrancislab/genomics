
#	20200720-TCGA-GBMLGG-RNA_bam/20240401-REdiscoverTE-TensorFlow


Using datasets provided by Eduardo.


https://ucsf.app.box.com/folder/256302309320?s=wi7wdk1n9mc27hc3xv2i2uuw2581y0jq

20230720-REdiscoverTE-Study > TCGA_Survival > Clean datasets


Train_datasets gbm_train.csv

Test_datasets gbm_test.csv


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
dir="20230720-REdiscoverTE-Study/TCGA_Survival/Clean datasets"
BOX_FILE="${BOX_BASE}/${dir}/Train_datasets/gbm_train.csv"
curl -netrc --output gbm_train.csv "${BOX_FILE}"
BOX_FILE="${BOX_BASE}/${dir}/Test_datasets/gbm_test.csv"
curl -netrc --output gbm_test.csv "${BOX_FILE}"
```

Quick check
```
awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print NF}' gbm_test.csv | uniq
3274
awk 'BEGIN{FPAT="([^,]*)|(\"[^\"]+\")"}{print NF}' gbm_train.csv | uniq
3274

awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS="\t"}{$1=$1;print}' gbm_test.csv > gbm_test.tsv
awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS="\t"}{$1=$1;print}' gbm_train.csv > gbm_train.tsv

awk -F"\t" '{print NF}' gbm_test.tsv | uniq
3274
awk -F"\t" '{print NF}' gbm_train.tsv | uniq
3274

```



Create a `SelectREs.txt`


```
join SelectREs.txt <( head -1 gbm_test.csv | tr , "\n" | sort | uniq | tr -d \" ) | wc -l
join: /dev/fd/63:424: is not sorted: LTR12
35
```




run TF in true GBM:
First model-with age, sex, CDKN2A, EGFR, etc
Second model- Age sex and RE’s
Third model-  age, sex, RE’s, CDKN2A, EGFR, etc


what is etc?

Are you thinking of using only the n=35 RE's that we've nominated as significant from the individual survival analyses?




Input
* Always include age and sex
* genes
  * CDKN2A and EGFR
  * None
* REs
  * All REs
  * select 35 REs (need to find what those REs are)
  * None

Predict
* Survival Months
* MGMT







project_id
primary_diagnosis
race
ethnicity
sex
RE_names
IDH
x1p19q
TERT
Tissue_sample_location
MGMT
Age
Survival_months
Vital_status
Tissue_source_site
Grade
IDH.codel.subtype
Chr.7.gain.Chr.10.loss
ATRX.status
BRAF.V600E.status
who_2021
who_simple
GBM
WHO2021_recode
diagnosis
EGFR_CNV
CDKN2A_CNV
who_grade
WHO2021_integrated
EGFR_re
CDKN2A_re


EGFR_CNV
EGFR_re
CDKN2A_CNV
CDKN2A_re



"TCGA-GBM","Glioblastoma","white","not hispanic or latino","male",
"06-0130-01A-01R-1849-01+1","WT","non-codel","","Henry Ford Hospital",
"Unmethylated",54,12.9448306,1,"Henry Ford Hospital",
"G4","IDHwt","No combined CNA","WT","WT",
"Glioblastoma, IDH-wildtype","Glioblastoma, IDH-wildtype","GBM",
"Glioblastoma, IDH-wt","",1,1,"G4",
"Glioblastoma, IDH-wt, G4","Amplified","Amplified"






```
module load WitteLab python3/3.9.1

./tf_nn.py -h
```




```
module load WitteLab python3/3.9.1

./tf_nn.py --attributes Age,sex --features_file AllREsMinusXs.txt --neuron_counts 512,256 --outcome_column Survival_months --final_layer continuous
mae:1.81 mse:6.72


./tf_nn.py --attributes Age,sex,CDKN2A_re,EGFR_re --features_file AllREsMinusXs.txt --neuron_counts 512,256 --outcome_column Survival_months --final_layer continuous
mae:1.61 mse:6.09





./tf_nn.py --attributes Age,sex --features_file SelectREs.txt --neuron_counts 512,256 --outcome_column Survival_months --final_layer continuous
mae:2.75 mse:13.18


./tf_nn.py --attributes Age,sex,CDKN2A_re,EGFR_re --features_file SelectREs.txt --neuron_counts 512,256 --outcome_column Survival_months --final_layer continuous
mae:2.74 mse:14.24


./tf_nn.py --attributes Age,sex,CDKN2A_re,EGFR_re --features_file SelectREs.txt --neuron_counts 128,64 --outcome_column Survival_months --final_layer continuous
mae:3.61 mse:23.7


./tf_nn.py --attributes Age,sex,CDKN2A_re,EGFR_re --features_file AllREsMinusXs.txt --neuron_counts 1024,512,256 --outcome_column Survival_months --final_layer continuous
mae:1.7 mse:6.56





./tf_nn.py --attributes Age,sex,CDKN2A_re,EGFR_re --features_file Select.txt --neuron_counts 512,256 --outcome_column MGMT --final_layer basic

80%

./tf_nn.py --attributes Age,sex --features_file AllREsMinusXs.txt --neuron_counts 512,256 --outcome_column MGMT --final_layer basic

95%

```



