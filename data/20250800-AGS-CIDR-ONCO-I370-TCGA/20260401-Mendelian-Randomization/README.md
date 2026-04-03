
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260401-Mendelian-Randomization


```bash

~/github/ucsffrancislab/Claude-Operon-Mendelian-Randomization/download_icvf_sumstats.sh

```



```bash
module load r

Rscript -e 'install.packages("data.table")'
Rscript -e 'remotes::install_github("MRCIEU/TwoSampleMR")'

```


```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=format --ntasks=1 --cpus-per-task=64 --mem=490G  --output="format_icvf_for_mr.log" --wrap="module load r; ~/github/ucsffrancislab/Claude-Operon-Mendelian-Randomization/format_icvf_for_mr.R"

```

```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=mr --ntasks=1 --cpus-per-task=64 --mem=490G  --output="run_bidirectional_mr.log" --wrap="module load r plink; ~/github/ucsffrancislab/Claude-Operon-Mendelian-Randomization/run_bidirectional_mr.R"

```


```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None --job-name=post --ntasks=1 --cpus-per-task=64 --mem=490G  --output="mr_postprocessing.log" --wrap="module load r plink; ~/github/ucsffrancislab/Claude-Operon-Mendelian-Randomization/mr_postprocessing.R"
```


