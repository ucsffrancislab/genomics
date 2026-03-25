
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260325-CustomPRSModels

Using the merged CIDR / MDSAML dataset now.


20260122-CustomPRSModels/edison_prs_case_control_analysis was used to create the pipeline

~/github/ucsffrancislab/edison_prs_case_control_analysis/ is the pipeline

20260122-CustomPRSModels/edison_prs_case_control_analysis_full_catalog was the local run on it


Running case/control on it.


```bash
dir=20260325-edison_prs_case_control_analysis_full_catalog/input
mkdir -p ${dir}

cp ../20260122-CustomPRSModels/edison_prs_lasso_survival_analysis/*-covariates.csv ${dir}/
cp ../20260122-CustomPRSModels/edison_prs_lasso_survival_analysis/*.scores.z-scores.txt.gz ${dir}/
chmod 600 ${dir}/*
\rm ${dir}/cidr*
chmod 400 ${dir}/*

```

pull in cidr's new dataset

```bash
dir=20260325-edison_prs_case_control_analysis_full_catalog/input

cp /francislab/data1/working/20250813-CIDR/20260323b-CustomPRSModels/pgs-calc-scores/scores.z-scores.txt.gz ${dir}/cidr.scores.z-scores.txt.gz
cp /francislab/data1/working/20250813-CIDR/20260320g-impute_pgs/cidr+mdsaml-covariates.csv ${dir}/cidr-covariates.csv

```


Quick check
```bash
dir=20260325-edison_prs_case_control_analysis_full_catalog/input

for f in $dir/*.scores.z-scores.txt.gz ; do echo $f; zcat $f | wc -l ; zcat $f | awk -F, '{print NF}' | uniq ; done
20260325-edison_prs_case_control_analysis_full_catalog/input/cidr.scores.z-scores.txt.gz
1542
5111
20260325-edison_prs_case_control_analysis_full_catalog/input/i370.scores.z-scores.txt.gz
4620
5111
20260325-edison_prs_case_control_analysis_full_catalog/input/onco.scores.z-scores.txt.gz
4366
5111
20260325-edison_prs_case_control_analysis_full_catalog/input/tcga.scores.z-scores.txt.gz
6717
5111


```



```bash
dir=20260325-edison_prs_case_control_analysis_full_catalog/input
cd ${dir}/..
for f in ~/github/ucsffrancislab/edison_prs_case_control_analysis/*{R,py,sh} ; do
ln -s $f
done

```



```bash
sbatch run_pipeline.sh --test

mkdir test
mv plots/ results/ slurm_*txt test/


sbatch run_pipeline.sh
box_upload.bash plots/* results/* slurm_*txt
```



Need to either modify the pipeline or the covariates to only process a subset of the cases.

Oh- can you please run the PGS meta analysis for the major subtypes? Lets do IDHwt, IDHmt, IDHmt 1p19q codel, IDHmt 1p19q intact




