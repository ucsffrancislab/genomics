
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260401-Mendelian-Randomization


```bash

~/github/ucsffrancislab/Claude-Mendelian-Randomization/download_icvf_sumstats.sh

```



```bash
module load r

Rscript -e 'install.packages("data.table")'
Rscript -e 'remotes::install_github("MRCIEU/TwoSampleMR")'

```


```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=format --ntasks=1 --cpus-per-task=64 --mem=490G  --output="format_icvf_for_mr.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/format_icvf_for_mr.R"

```

```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=64 --mem=490G  --output="run_bidirectional_mr.log" --wrap="module load r plink; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_bidirectional_mr.R"

```


```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=post --ntasks=1 --cpus-per-task=64 --mem=490G  --output="mr_postprocessing.log" --wrap="module load r plink; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/mr_postprocessing.R"
```



```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=hla_sensitivity --ntasks=1 --cpus-per-task=64 --mem=490G  --output="run_hla_sensitivity.log" --wrap="module load r plink; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_hla_sensitivity.R"
```





##	20260406



```bash
output_dir="mr_results-20260406b"
mkdir -p ${output_dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=16 --mem=120G  --output="${output_dir}/run_bidirectional_mr.log" --wrap="module load r plink; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_bidirectional_mr.R --output-dir ${output_dir}"

box_upload.bash ${output_dir}/*[gv] ${output_dir}/plots/*
```

Out of memory with just 16/120G. Uploading results anyway to see.







Doubling ....


```bash
output_dir="mr_results-20260407a"
mkdir -p ${output_dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${output_dir}/run_bidirectional_mr.log" --wrap="module load r plink; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_bidirectional_mr.R --output-dir ${output_dir}"

```

New updates

```bash
output_dir="mr_results-20260407b"
mkdir -p ${output_dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${output_dir}/run_bidirectional_mr.log" --wrap="module load r plink; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_bidirectional_mr.R --output-dir ${output_dir}"

```


Not sure if "module load plink" is needed as it appears to be running plink from one of the R packages...

```bash
/c4/home/gwendt/.R/rocky8-x86_64-pc-linux-gnu-library/4.5-CBI-gcc13/genetics.binaRies/bin/plink
```


New updates

```bash
output_dir="mr_results-20260407c"
mkdir -p ${output_dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${output_dir}/run_bidirectional_mr.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_bidirectional_mr.R --output-dir ${output_dir}"

```




```bash
output_dir="mr_results-20260407c"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=post --ntasks=1 --cpus-per-task=64 --mem=490G  --output="${output_dir}/mr_postprocessing.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/mr_postprocessing.R --output-dir ${output_dir}"
```



```bash
output_dir="mr_results-20260407c"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=hla_sensitivity --ntasks=1 --cpus-per-task=64 --mem=490G  --output="${output_dir}/run_hla_sensitivity.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_hla_sensitivity.R --output-dir ${output_dir}"
```


```bash
output_dir="mr_results-20260407c"
box_upload.bash ${output_dir}/*[gv] ${output_dir}/{plots,hla_excluded,interpretation}/*
```





##	20260408 - MVMR


```bash

~/github/ucsffrancislab/Claude-Mendelian-Randomization/download_mvmr_sumstats.sh

```

```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=format --ntasks=1 --cpus-per-task=16 --mem=120G  --output="format_mvmr_for_mr.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/format_mvmr_for_mr.R"

```


```bash
output_dir="mvmr_results-20260409a"
mkdir -p ${output_dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${output_dir}/run_mvmr.log" --wrap="module load r ; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_mvmr.R --output-dir ${output_dir}"

```



```bash
output_dir="mvmr_results-20260409b"
mkdir -p ${output_dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${output_dir}/run_mvmr.log" --wrap="module load r ; ~/github/ucsffrancislab/Claude-Mendelian-Randomization/run_mvmr.R --output-dir ${output_dir}"

box_upload.bash ${output_dir}/*[vg] ${output_dir}/plots/*
```




