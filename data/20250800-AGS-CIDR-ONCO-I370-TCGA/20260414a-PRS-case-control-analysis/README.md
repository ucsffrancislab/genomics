
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


```bash
sbatch --job-name ccidhwt ~/github/ucsffrancislab/edison_prs_case_control_analysis/run_pipeline.sh \
  --outdir idhwt_cases-20260415  --idh-subtype wt
sbatch --job-name ccidhmt ~/github/ucsffrancislab/edison_prs_case_control_analysis/run_pipeline.sh \
  --outdir idhmt_cases-20260415  --idh-subtype mt
sbatch --job-name ccidhmtcodel ~/github/ucsffrancislab/edison_prs_case_control_analysis/run_pipeline.sh \
  --outdir idhmt_codel-20260415  --idh-subtype mt --pq-subtype codel
sbatch --job-name ccidhmtintact ~/github/ucsffrancislab/edison_prs_case_control_analysis/run_pipeline.sh \
  --outdir idhmt_intact-20260415 --idh-subtype mt --pq-subtype intact


box_upload.bash $( find idh*-20260415/ -type f )
```

