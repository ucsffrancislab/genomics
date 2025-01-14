
#	Geno/AGS_Ig_Analysis

The included covariate file (Cleaned_Covariates_with_HLA.tsv) was generated using the script Box-Box/Francis _Lab_Share/20241024_IgE_IgG_AGS/Scripts/IgG_IgE_analysis.Rmd 

This .Rmd file should be able to offer clarity into the definitions of variables. The HLA types are coded as 0 1 or 2, based on the number of copies of that HLA allele. This was abstracted from the SNP2HLA imputed data. 

The Adult Glioma Study Folder in the Box Francis Lab Share folder should have data dictionaries for any other variables of interest. 


```
grep -h "^library" IgG_IgE_analysis.Rmd HLA_VZV_score_AGS.Rmd | sed -e 's/library(//' -e 's/)//' -e 's/"//g' | sort | uniq | paste -sd, | sed -e 's/,/","/g'
AF","cobalt","corrplot","dplyr","DT","ggplot2","ggpubr","interactionR","knitr","marginaleffects","MatchIt","metafor","osqp","partDSA","quickmatch","randomForest","RColorBrewer","reshape2","rstatix","stats","survival","survminer","UpSetR","WeightIt

```


```
module load r

R

BiocManager::install(c("AF","cobalt","corrplot","dplyr","DT","ggplot2","ggpubr","interactionR","knitr","marginaleffects","MatchIt","metafor","osqp","partDSA","quickmatch","randomForest","RColorBrewer","reshape2","rstatix","stats","survival","survminer","UpSetR","WeightIt"))

```




```
./IgG_IgE_analysis.Rmd --output_dir ${PWD}/Results \
 --AGSfile /francislab/data1/users/gguerra/20211112-Viral-Glioma-SES-study/Data/AGS_Covariates_Updated_2022-11-03.csv \
 --IgEfile /francislab/data1/users/gguerra/20200527_Adult_Glioma_Study/Summary_stats/AGS_IgE_measurements_2023-10-06.csv \
 --survfile /francislab/data1/users/gguerra/20200527_Adult_Glioma_Study/Summary_stats/AGS_survival_update_2023-05-18.csv \
 --AGSagefile /francislab/data1/users/gguerra/20200527_Adult_Glioma_Study/Summary_stats/AGS_age_update_2024-05-31.csv

```

