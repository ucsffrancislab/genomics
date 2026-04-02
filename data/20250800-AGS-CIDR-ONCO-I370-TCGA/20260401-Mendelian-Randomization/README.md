
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




