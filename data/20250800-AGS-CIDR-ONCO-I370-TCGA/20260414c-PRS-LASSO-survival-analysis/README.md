
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260414c-PRS-LASSO-survival-analysis

```bash
mkdir input
cd input
for ds in cidr i370 onco tcga ; do
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/${ds}-covariates.csv
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/pgs-calc-scores/${ds}/scores.z-scores.txt.gz ${ds}.scores.z-scores.txt.gz
done
```


```bash
sbatch --job-name fixed ~/github/ucsffrancislab/edison_prs_lasso_survival_analysis/run_pipeline.sh \
  --cv-strategy fixed --datadir input --outdir results-fixed-20260415
sbatch --job-name loco ~/github/ucsffrancislab/edison_prs_lasso_survival_analysis/run_pipeline.sh \
  --cv-strategy loco --datadir input --outdir results-loco-20260415
sbatch --job-name random ~/github/ucsffrancislab/edison_prs_lasso_survival_analysis/run_pipeline.sh \
  --cv-strategy random_split --datadir input --outdir results-random_split-20260415
```


```bash
box_upload.bash $( find results-*/ -type f )

```


