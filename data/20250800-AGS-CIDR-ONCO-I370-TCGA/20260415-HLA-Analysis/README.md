
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260415-HLA-Analysis

Running Claude's HLA Analysis

Add HWE filters?

Change MAF filters?

If not, this is unnecessary.



```bash
dir=results-20260415
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
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/cidr-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/i370-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/onco-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/tcga-covariates.csv \
  --dataset-names CIDR I370 ONCO TCGA \
  --sensitivity-analysis \
  --haplotype-analysis \
  --workers 32 \
  --output-dir ${dir}"
```


```bash
box_upload.bash $( find results-20260415/ -type f )
```


See if the same HLA needs conditional analysis



```bash
dir=results-20260415
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
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/cidr-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/i370-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/onco-covariates.csv \
   /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/tcga-covariates.csv \
  --dataset-names CIDR I370 ONCO TCGA \
  --conditional-only \
  --conditional-analysis 'HLA_DPB1*04:01' \
  --workers 32 \
  --output-dir ${dir}"

```



