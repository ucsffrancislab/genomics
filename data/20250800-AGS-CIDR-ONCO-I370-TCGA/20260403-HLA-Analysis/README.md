
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260403-HLA-Analysis

Running Claude's HLA Analysis


```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None \
  --job-name=HLA --ntasks=1 --cpus-per-task=64 --mem=490G  --output="HLA-Analysis.log" \
  --wrap="python3 -m hla_analysis \
  --dosage-files \
   /francislab/data1/working/20250813-CIDR/20260320h-impute_hla/hla-cidr-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-i370-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-onco-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-tcga-hg19/chr6.dose.vcf.gz \
  --covariate-files \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/cidr-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/i370-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/onco-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/tcga-covariates.csv \
  --dataset-names CIDR I370 ONCO TCGA \
  --sensitivity-analysis \
  --workers 64 \
  --output-dir results-20260403/"

```


```bash
box_upload.bash results/*[vg] results/plots/*
```

##	20260406

```bash
dir=results-20260406b
mkdir -p ${dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None \
  --job-name=HLA --ntasks=1 --cpus-per-task=16 --mem=120G  --output="${dir}/HLA-Analysis.log" \
  --wrap="python3 -m hla_analysis \
  --dosage-files \
   /francislab/data1/working/20250813-CIDR/20260320h-impute_hla/hla-cidr-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-i370-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-onco-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-tcga-hg19/chr6.dose.vcf.gz \
  --covariate-files \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/cidr-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/i370-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/onco-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/tcga-covariates.csv \
  --dataset-names CIDR I370 ONCO TCGA \
  --sensitivity-analysis \
  --haplotype-analysis \
  --workers 16 \
  --output-dir ${dir}"

```


```bash
dir=results-20260406b
box_upload.bash ${dir}/*log ${dir}/*/*v ${dir}/*/plots/*
```




##	20260407

```bash
dir=results-20260407
mkdir -p ${dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None \
  --job-name=HLA --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${dir}/HLA-Analysis.log" \
  --wrap="python3 -m hla_analysis \
  --dosage-files \
   /francislab/data1/working/20250813-CIDR/20260320h-impute_hla/hla-cidr-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-i370-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-onco-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-tcga-hg19/chr6.dose.vcf.gz \
  --covariate-files \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/cidr-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/i370-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/onco-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/tcga-covariates.csv \
  --dataset-names CIDR I370 ONCO TCGA \
  --sensitivity-analysis \
  --haplotype-analysis \
  --conditional-analysis 'HLA_DPB1*04:01' \
  --workers 32 \
  --output-dir ${dir}"

```





```bash
dir=results-20260407
mkdir -p ${dir}

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 --export=None \
  --job-name=HLA --ntasks=1 --cpus-per-task=32 --mem=240G  --output="${dir}/HLA-Analysis-conditional.log" \
  --wrap="python3 -m hla_analysis \
  --dosage-files \
   /francislab/data1/working/20250813-CIDR/20260320h-impute_hla/hla-cidr-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-i370-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-onco-hg19/chr6.dose.vcf.gz \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250725-hla/hla-tcga-hg19/chr6.dose.vcf.gz \
  --covariate-files \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/cidr-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/i370-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/onco-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/tcga-covariates.csv \
  --dataset-names CIDR I370 ONCO TCGA \
  --conditional-analysis 'HLA_DPB1*04:01' \
  --conditional-only \
  --output-dir results-20260407/"
```






```bash
dir=results-20260407
box_upload.bash ${dir}/*log ${dir}/*/*v ${dir}/*/plots/*
```

