
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260401-Mendelian-Randomization


Need to wait for the completion of the summary stats



```bash
ln -s ~/github/ucsffrancislab/Claude-Mendelian-Randomization/icvf_pgs_to_big40_mapping.csv
```

I've already downloaded these. Perhaps I should move them to /refs/.
Nevertheless, just link to them

```bash
#	~/github/ucsffrancislab/Claude-Mendelian-Randomization/download_icvf_sumstats.sh

ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260401-Mendelian-Randomization/icvf_gwas_sumstats
```

```bash
module load r

Rscript -e 'install.packages("data.table")'
Rscript -e 'remotes::install_github("MRCIEU/TwoSampleMR")'
```

Already did this so link to those results.
```bash
#	sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=format --ntasks=1 --cpus-per-task=16 --mem=120G  --output="format_icvf_for_mr.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/format_icvf_for_mr.R"

ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260401-Mendelian-Randomization/icvf_mr_ready
```


```bash
output_dir="mr_results-20260420"
mkdir -p ${output_dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${output_dir}/run_bidirectional_mr.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_bidirectional_mr.R --glioma-dir /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260414d-GWAS-summary-stats/results-20260415 --output-dir ${output_dir}"

```



tail -f mr_results-20260420/run_bidirectional_mr.log 


--- Next steps ---
  Run mr_postprocessing.R for interpretation, heatmap, and tiered forest plot
  Apply Bonferroni correction: 18 tracts x 5 subtypes = 90 tests -> p < 5.6e-4
  Consider excluding HLA region instruments (chr6:25-34Mb) for robustness
slurmstepd: error: Detected 1587 oom-kill event(s) in StepId=1108728.batch. Some of your processes may have been killed by the cgroup out-of-memory handler.







```bash
output_dir="mr_results-20260420"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=post --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${output_dir}/mr_postprocessing.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/mr_postprocessing.R --glioma-dir /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260414d-GWAS-summary-stats/results-20260415 --output-dir ${output_dir}"
```



```bash
output_dir="mr_results-20260420"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=hla_sensitivity --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${output_dir}/run_hla_sensitivity.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_hla_sensitivity.R --glioma-dir /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260414d-GWAS-summary-stats/results-20260415 --output-dir ${output_dir}"
```


```bash
output_dir="mr_results-20260420"
box_upload.bash ${output_dir}/*[gv] ${output_dir}/{plots,hla_excluded,interpretation}/*
```







##	MVMR


```bash
ln -s ~/github/ucsffrancislab/Claude-Mendelian-Randomization/mvmr_additional_metrics_mapping.csv 
```

I've already downloaded these. Perhaps I should move them to /refs/.
Nevertheless, just link to them

```bash
#	~/github/ucsffrancislab/Claude-Mendelian-Randomization/download_mvmr_sumstats.sh

ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260401-Mendelian-Randomization/mvmr_gwas_sumstats
```

Already did this as well so just link them.
```bash
#	sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=format --ntasks=1 --cpus-per-task=16 --mem=120G  --output="format_mvmr_for_mr.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/format_mvmr_for_mr.R"

ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260401-Mendelian-Randomization/mvmr_mr_ready
```


```bash
output_dir="mvmr_results-20260420"
mkdir -p ${output_dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mvmr --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${output_dir}/run_mvmr.log" --wrap="module load r ; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_mvmr.R --glioma-dir /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260414d-GWAS-summary-stats/results-20260415 --output-dir ${output_dir}"




box_upload.bash ${output_dir}/*[vg] ${output_dir}/plots/*
```




