
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260414a-PRS-case-control-analysis

```bash
mkdir input
cd input
for ds in cidr i370 onco tcga ; do
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/${ds}-covariates.csv
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/pgs-calc-scores/${ds}/scores.z-scores.txt.gz ${ds}.scores.z-scores.txt.gz
done
```

```bash
sbatch --job-name cctest ~/github/ucsffrancislab/edison_prs_case_control_analysis/run_pipeline.sh --test --outdir test-20260415

box_upload.bash $( find test-20260415/ -type f )
```


```bash
sbatch --job-name ccall ~/github/ucsffrancislab/edison_prs_case_control_analysis/run_pipeline.sh --outdir allcases-20260415

box_upload.bash $( find allcases-20260415/ -type f )
```

