
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_case_control_analysis

There are currently no cases in CIDR so it will not be included at all here.

```bash

mkdir upload
../normalize_covariates.bash i370 ../pgs-calc-scores-merged/i370/i370-covariates.tsv > upload/i370-covariates.csv
../normalize_covariates.bash onco ../pgs-calc-scores-merged/onco/onco-covariates.tsv > upload/onco-covariates.csv
../normalize_covariates.bash tcga ../pgs-calc-scores-merged/tcga/tcga-covariates.tsv > upload/tcga-covariates.csv
chmod -w upload/*-covariates.csv

for d in i370 onco tcga ; do
  cp ../edison_prs_survival_analysis/${d}.scores.z-scores.txt.gz upload/
done


```

https://claude.ai/chat/81868de0-9fc9-49a3-8a33-d1901346d8a1

```bash 

edison_prs_case_control_analysis_prompt.py

```


