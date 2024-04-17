
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



./tf_nn.py --attributes Age,sex,CDKN2A_re,EGFR_re --neuron_counts 64,32 --outcome_column MGMT --final_layer basic
```






##	20240402

NOTE that all that is below ended badly. The splitting of data into train and test resulted in some in both and some in none.
This performed great, but is quite wrong. Redoing with a sigh.

```
ln -s ../20200808-REdiscoverTE/REdiscoverTE_rollup_noquestion/RE_all_2_counts_normalized.tsv 
ln -s ../20200808-REdiscoverTE/REdiscoverTE_rollup_noquestion/GENE_2_counts_normalized.tsv 
```

Redo with a different matrix and with no duplicated subjects

Only deceased.

```
head -q -n 1  gbm_train.tsv gbm_test.tsv | cut -f1,3248,3250-3252,3254-3257,3273,3274 | uniq > metadata.tsv
tail -q -n +2 gbm_train.tsv gbm_test.tsv | cut -f1,3248,3250-3252,3254-3257,3273,3274 | sort | uniq | awk -F"\t" '($9==1)' >> metadata.tsv

sed -i 's/\"//g' metadata.tsv
dos2unix metadata.tsv 
sed -i 's/\t/;/g' metadata.tsv

```

join doesn't work with tab separated

```
awk 'BEGIN{FS=OFS="\t"}{split($1,a,"-");$1=a[1]"-"a[2];if(!seen[$1]){seen[$1]++;print}}' GENE_2_counts_normalized.tsv > GENE_2_counts_normalized.subject_unique.tsv

sed -i 's/\t/;/g' GENE_2_counts_normalized.subject_unique.tsv

join -t\; --header metadata.tsv GENE_2_counts_normalized.subject_unique.tsv > GENE_2_counts_normalized.subject_unique.metadata.tsv

sed -i 's/;/\t/g' GENE_2_counts_normalized.subject_unique.metadata.tsv

```




```
wc -l  GENE_2_counts_normalized.subject_unique.metadata.tsv
78 GENE_2_counts_normalized.subject_unique.metadata.tsv

head -1 GENE_2_counts_normalized.tsv | tr "\t" "\n" > AllGenes.txt


head -1 GENE_2_counts_normalized.subject_unique.metadata.tsv > GENE_2_counts_normalized.subject_unique.metadata.train.tsv
head -1 GENE_2_counts_normalized.subject_unique.metadata.tsv > GENE_2_counts_normalized.subject_unique.metadata.test.tsv
tail -n +2 GENE_2_counts_normalized.subject_unique.metadata.tsv |shuf|shuf|shuf| > tmp
head -60 tmp | sort >> GENE_2_counts_normalized.subject_unique.metadata.train.tsv
tail -n 17 tmp | sort >> GENE_2_counts_normalized.subject_unique.metadata.test.tsv


#tail -n +2 GENE_2_counts_normalized.subject_unique.metadata.tsv |shuf|shuf|shuf| tee >(head -60 | sort>> GENE_2_counts_normalized.subject_unique.metadata.${i}.train.tsv) | tail -n 17 | sort>> GENE_2_counts_normalized.subject_unique.metadata.${i}.test.tsv

for i in $( seq 0 9 ) ; do
echo $i
head -1 GENE_2_counts_normalized.subject_unique.metadata.tsv > GENE_2_counts_normalized.subject_unique.metadata.${i}.train.tsv
head -1 GENE_2_counts_normalized.subject_unique.metadata.tsv > GENE_2_counts_normalized.subject_unique.metadata.${i}.test.tsv
tail -n +2 GENE_2_counts_normalized.subject_unique.metadata.tsv |shuf|shuf|shuf > tmp
head -60 tmp | sort >> GENE_2_counts_normalized.subject_unique.metadata.${i}.train.tsv
tail -n 17 tmp | sort >> GENE_2_counts_normalized.subject_unique.metadata.${i}.test.tsv
done
```







```
./tf_nn.py --attributes Age,sex --features_file AllGenes.txt --neuron_counts 512,256 --outcome_column MGMT --final_layer basic --train_matrix GENE_2_counts_normalized.subject_unique.metadata.train.tsv --test_matrix GENE_2_counts_normalized.subject_unique.metadata.test.tsv

2/2 [==============================] - 0s 78ms/step - loss: 1.1311e-09 - accuracy: 1.0000
1/1 [==============================] - 0s 300ms/step - loss: nan - accuracy: 1.0000
         MGMT  prediction
IID                      
76-4928     1         1.0
12-3653     0         0.0
14-2554     0         0.0
32-2615     0         0.0
27-1832     0         0.0
27-2526     0         0.0
27-2523     1         1.0
76-4929     1         1.0
76-4931     0         0.0
06-1804     1         1.0
19-2620     1         1.0
06-2559     1         1.0
41-2572     0         0.0
27-1830     0         0.0
27-2528     1         1.0
06-5411     0         0.0
41-2571     0         NaN


```


```
./tf_nn.py --attributes Age,sex --features_file AllGenes.txt --neuron_counts 512,256 --outcome_column Survival_months --final_layer continuous --train_matrix GENE_2_counts_normalized.subject_unique.metadata.train.tsv --test_matrix GENE_2_counts_normalized.subject_unique.metadata.test.tsv




```






```
mkdir logs
for i in $( seq 0 9 ) ; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="MGMT-${i}" --output="${PWD}/logs/tf_nn.Genes.MGMT.${i}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=8 --mem=60G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ./tf_nn.py --attributes Age,sex --features_file ${PWD}/AllGenes.txt --neuron_counts 256,128 --outcome_column MGMT --final_layer basic --train_matrix ${PWD}/GENE_2_counts_normalized.subject_unique.metadata.${i}.train.tsv --test_matrix ${PWD}/GENE_2_counts_normalized.subject_unique.metadata.${i}.test.tsv"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="Survival-${i}" --output="${PWD}/logs/tf_nn.Genes.Survival_months.${i}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=8 --mem=60G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ./tf_nn.py --attributes Age,sex --features_file ${PWD}/AllGenes.txt --neuron_counts 512,256 --outcome_column Survival_months --final_layer continuous --train_matrix ${PWD}/GENE_2_counts_normalized.subject_unique.metadata.${i}.train.tsv --test_matrix ${PWD}/GENE_2_counts_normalized.subject_unique.metadata.${i}.test.tsv --epochs 500"

done


```




---



```
awk 'BEGIN{FS=OFS="\t"}{split($1,a,"-");$1=a[1]"-"a[2];if(!seen[$1]){seen[$1]++;print}}' RE_all_2_counts_normalized.tsv > RE_all_2_counts_normalized.subject_unique.tsv

sed -i 's/\t/;/g' RE_all_2_counts_normalized.subject_unique.tsv

join -t\; --header metadata.tsv RE_all_2_counts_normalized.subject_unique.tsv > RE_all_2_counts_normalized.subject_unique.metadata.tsv

sed -i 's/;/\t/g' RE_all_2_counts_normalized.subject_unique.metadata.tsv

```


```
wc -l  RE_all_2_counts_normalized.subject_unique.metadata.tsv
78 RE_all_2_counts_normalized.subject_unique.metadata.tsv

head -1 RE_all_2_counts_normalized.tsv | tr "\t" "\n" > AllRE_all.txt


for i in $( seq 0 9 ) ; do
echo $i
head -1 RE_all_2_counts_normalized.subject_unique.metadata.tsv > RE_all_2_counts_normalized.subject_unique.metadata.${i}.train.tsv
head -1 RE_all_2_counts_normalized.subject_unique.metadata.tsv > RE_all_2_counts_normalized.subject_unique.metadata.${i}.test.tsv
tail -n +2 RE_all_2_counts_normalized.subject_unique.metadata.tsv |shuf|shuf|shuf > tmp
head -60 tmp | sort >> RE_all_2_counts_normalized.subject_unique.metadata.${i}.train.tsv
tail -n 17 tmp | sort >> RE_all_2_counts_normalized.subject_unique.metadata.${i}.test.tsv
done
```



```
mkdir logs
for i in $( seq 0 9 ) ; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="MGMT-${i}" --output="${PWD}/logs/tf_nn.RE.MGMT.${i}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=8 --mem=60G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ./tf_nn.py --attributes Age,sex --features_file ${PWD}/AllRE_all.txt --neuron_counts 512,256 --outcome_column MGMT --final_layer basic --train_matrix ${PWD}/RE_all_2_counts_normalized.subject_unique.metadata.${i}.train.tsv --test_matrix ${PWD}/RE_all_2_counts_normalized.subject_unique.metadata.${i}.test.tsv"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="Survival-${i}" --output="${PWD}/logs/tf_nn.RE.Survival_months.${i}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=8 --mem=60G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ./tf_nn.py --attributes Age,sex --features_file ${PWD}/AllRE_all.txt --neuron_counts 512,256 --outcome_column Survival_months --final_layer continuous --train_matrix ${PWD}/RE_all_2_counts_normalized.subject_unique.metadata.${i}.train.tsv --test_matrix ${PWD}/RE_all_2_counts_normalized.subject_unique.metadata.${i}.test.tsv --epochs 1000 "

done

```




##	20240404



Trying to refine the model, but I have my doubts

```
for i in $( seq 0 9 ) ; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="MGMT-${i}" --output="${PWD}/logs/tf_nn.Genes.MGMT.${i}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=8 --mem=60G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ./tf_nn.py --attributes Age,sex --features_file ${PWD}/AllGenes.txt --neuron_counts 32,16 --outcome_column MGMT --final_layer basic --train_matrix ${PWD}/GENE_2_counts_normalized.subject_unique.metadata.${i}.train.tsv --test_matrix ${PWD}/GENE_2_counts_normalized.subject_unique.metadata.${i}.test.tsv --epochs 200"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="Survival-${i}" --output="${PWD}/logs/tf_nn.Genes.Survival_months.${i}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=8 --mem=60G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ./tf_nn.py --attributes Age,sex --features_file ${PWD}/AllGenes.txt --neuron_counts 32,16 --outcome_column Survival_months --final_layer continuous --train_matrix ${PWD}/GENE_2_counts_normalized.subject_unique.metadata.${i}.train.tsv --test_matrix ${PWD}/GENE_2_counts_normalized.subject_unique.metadata.${i}.test.tsv --epochs 200"


sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="MGMT-${i}" --output="${PWD}/logs/tf_nn.RE.MGMT.${i}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=8 --mem=60G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ./tf_nn.py --attributes Age,sex --features_file ${PWD}/AllRE_all.txt --neuron_counts 32,16 --outcome_column MGMT --final_layer basic --train_matrix ${PWD}/RE_all_2_counts_normalized.subject_unique.metadata.${i}.train.tsv --test_matrix ${PWD}/RE_all_2_counts_normalized.subject_unique.metadata.${i}.test.tsv --epochs 200"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name="Survival-${i}" --output="${PWD}/logs/tf_nn.RE.Survival_months.${i}.$( date "+%Y%m%d%H%M%S%N" ).out" --time=14000 --nodes=1 --ntasks=8 --mem=60G --exclude=c4-n37,c4-n38,c4-n39 --wrap="module load WitteLab python3/3.9.1; ./tf_nn.py --attributes Age,sex --features_file ${PWD}/AllRE_all.txt --neuron_counts 32,16 --outcome_column Survival_months --final_layer continuous --train_matrix ${PWD}/RE_all_2_counts_normalized.subject_unique.metadata.${i}.train.tsv --test_matrix ${PWD}/RE_all_2_counts_normalized.subject_unique.metadata.${i}.test.tsv --epochs 200"

done
```





