
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260414b-PRS-survival-analysis

```bash
mkdir input
cd input
for ds in cidr i370 onco tcga ; do
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/${ds}-covariates.csv
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/pgs-calc-scores/${ds}/scores.z-scores.txt.gz ${ds}.scores.z-scores.txt.gz
done
```

```bash
~/github/ucsffrancislab/edison_prs_survival_analysis/create_model_list.py \
    --scores input/cidr.scores.z-scores.txt.gz \
    --output input/model_list.txt

sbatch ~/github/ucsffrancislab/edison_prs_survival_analysis/run_pipeline.sh --models input/model_list.txt --outdir results-20260415

box_upload.bash $( find results-20260415/ -type f )
```







```bash
cat << EOF > model_list.txt
idhmut_1p19qcodel_scoring_system
idhmut_1p19qnoncodel_scoring_system
idhmut_scoring_system
idhwt_scoring_system
allGlioma_scoring_system
gbm_scoring_system
nonGbm_scoring_system
PGS000155
PGS000781
PGS002302
PGS003384
EOF

sbatch ~/github/ucsffrancislab/edison_prs_survival_analysis/run_pipeline.sh 
```

