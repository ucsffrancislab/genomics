
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_lasso_survival_analysis


```bash

for f in ~/github/ucsffrancislab/edison_prs_lasso_survival_analysis/*{sh,py}; do
ln -s $f
done


sbatch slurm_single_job.sh

```


```bash

box_upload.bash results/results_summary.json results/*/*

```


Challenge Edison on it running it

Run the tests


