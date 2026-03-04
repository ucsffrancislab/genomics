
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_survival_analysis_glioma2



```bash

for f in ../edison_prs_survival_analysis/*-covariates.csv ../edison_prs_survival_analysis/*.scores.info ../edison_prs_survival_analysis/*.scores.z-scores.txt.gz ../edison_prs_survival_analysis_glioma/model_list.txt /c4/home/gwendt/github/ucsffrancislab/edison_prs_survival_analysis/*.sh /c4/home/gwendt/github/ucsffrancislab/edison_prs_survival_analysis/*.py ; do
echo $f
ln -s $f
done


sbatch run_parallel_survival.sh 

```
