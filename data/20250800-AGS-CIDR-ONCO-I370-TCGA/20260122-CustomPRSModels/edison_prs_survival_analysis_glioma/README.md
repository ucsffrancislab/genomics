
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_survival_analysis_glioma


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

sbatch run_parallel_survival.sh 
```



