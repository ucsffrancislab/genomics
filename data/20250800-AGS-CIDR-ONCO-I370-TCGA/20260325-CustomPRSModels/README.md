
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



```bash

sbatch --job-name=test_run --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir test_run     --test
sbatch --job-name=all_cases --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir all_cases
sbatch --job-name=idhwt --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir idhwt_cases  --idh-subtype wt
sbatch --job-name=idhmt --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir idhmt_cases  --idh-subtype mt
sbatch --job-name=idhmt_codel --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir idhmt_codel  --idh-subtype mt --pq-subtype codel
sbatch --job-name=idhmt_intact --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir idhmt_intact --idh-subtype mt --pq-subtype intact

box_upload.bash test_run/* all_cases/* idhwt_cases/* idhmt_cases/* idhmt_codel/* idhmt_intact/*
```



```bash

sbatch --job-name=test_run --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/test_run --test
sbatch --job-name=test_run_m --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/test_run_m --test --sex M
sbatch --job-name=test_run_f --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/test_run_f --test --sex F
sbatch --job-name=all --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/all
sbatch --job-name=all_m --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/all_m --sex M
sbatch --job-name=all_f --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/all_f --sex F
sbatch --job-name=idhwt --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/idhwt  --idh-subtype wt
sbatch --job-name=idhwt_m --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/idhwt_m  --idh-subtype wt --sex M
sbatch --job-name=idhwt_f --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/idhwt_f  --idh-subtype wt --sex F
sbatch --job-name=idhmt --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/idhmt  --idh-subtype mt
sbatch --job-name=idhmt_m --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/idhmt_m  --idh-subtype mt --sex M
sbatch --job-name=idhmt_f --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/idhmt_f  --idh-subtype mt --sex F
sbatch --job-name=idhmt_codel --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/idhmt_codel  --idh-subtype mt --pq-subtype codel
sbatch --job-name=idhmt_intact --ntasks=1 --cpus-per-task=16 --mem=120G run_pipeline.sh --outdir sex/idhmt_intact --idh-subtype mt --pq-subtype intact

box_upload.bash sex/*/*
```


