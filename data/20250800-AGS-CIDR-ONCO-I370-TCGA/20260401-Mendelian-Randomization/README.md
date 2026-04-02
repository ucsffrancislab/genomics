
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260401-Mendelian-Randomization


```bash

./download_icvf_sumstats.sh

```



```bash
module load r

Rscript -e 'install.packages("data.table")'
Rscript -e 'remotes::install_github("MRCIEU/TwoSampleMR")'

```


```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=format --ntasks=1 --cpus-per-task=64 --mem=490G  --output="format.log" --wrap="module load r; format_icvf_for_mr.R"

```

```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=64 --mem=490G  --output="mr.log" --wrap="module load r; run_bidirectional_mr.R"

```



Next steps:
1. Load glioma GWAS as outcome data
2. Harmonise with: harmonise_data(exposure_dat, outcome_dat)
3. Run MR:         mr(harmonised_dat)
4. Sensitivity:    mr_pleiotropy_test(), mr_heterogeneity()






