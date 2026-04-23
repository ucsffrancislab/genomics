
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260414d-GWAS-summary-stats

Developed a GWAS summary stats pipeline

https://claude.ai/chat/1ff6d67a-f2ea-4a29-9cdf-39a5c758c43c


```bash

~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh -h

echo -e "dataset\tvcf_dir\tcovariate_file" > datasets.tsv
echo -e "cidr\t/francislab/data1/working/20250813-CIDR/20260320f-impute_genotypes/imputed-umich-cidr\t/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/cidr-covariates.csv" >> datasets.tsv
for ds in i370 onco tcga ; do
echo -e "${ds}\t/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-${ds}\t/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19/${ds}-covariates.csv" >> datasets.tsv
done

```

Including default values on the command line for clarity

```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=test_run --ntasks=1 --cpus-per-task=8 --mem=60G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --test --outdir results-20260415/test_run 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=test_run --ntasks=1 --cpus-per-task=8 --mem=60G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --test --outdir results-20260415/test_run2

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=test_run --ntasks=1 --cpus-per-task=8 --mem=60G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.3 --maf 0.01 --hwe 1e-6 \
 --test --outdir results-20260415/test_run3


box_upload.bash $( find results-20260415/ \( -name "*pdf" -o -name "*png" \) )

```







```bash
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=all --ntasks=1 --cpus-per-task=16 --mem=120G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.3 --maf 0.01 --hwe 1e-6 \
 --outdir results-20260415/all_glioma 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhwt --ntasks=1 --cpus-per-task=16 --mem=120G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --outdir results-20260415/idhwt --idh-subtype wt 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhmt --ntasks=1 --cpus-per-task=16 --mem=120G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --outdir results-20260415/idhmt --idh-subtype mt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhmtcodel --ntasks=1 --cpus-per-task=16 --mem=120G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --outdir results-20260415/idhmt_codel --idh-subtype mt --pq-subtype codel 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhmtintact --ntasks=1 --cpus-per-task=16 --mem=120G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --outdir results-20260415/idhmt_intact --idh-subtype mt --pq-subtype intact
```



```bash
dir=results-20260415
sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time=14-0 \
 --job-name=cross --ntasks=1 --cpus-per-task=64 --mem=490G \
 --output="${PWD}/${dir}/cross_subtype.$( date "+%Y%m%d%H%M%S%N" ).log" \
 --wrap="python3 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/scripts/10_cross_subtype.py \
    --result-dirs ${dir}/all_glioma \
                  ${dir}/idhwt \
                  ${dir}/idhmt \
                  ${dir}/idhmt_intact \
                  ${dir}/idhmt_codel \
    --outdir ${dir}/cross_subtype"
```


```bash

#box_upload.bash $( find results-20260415/ -type f -not -path \*/filtered_vcf/\* -not -path \*meta_result_1.tbl -not -path \*.pheno.glm.logistic.hybrid )

find results-20260415/ -type f -path \*/final/\* -not -path \*/filtered_vcf/\* -not -path \*meta_result_1.tbl -not -path \*.pheno.glm.logistic.hybrid -not -path \*test_run\*/\* -ls | awk '{print $7}' | datamash sum 1

#box_upload.bash $( find results-20260415/ -type f -path \*/final/\* -not -path \*/filtered_vcf/\* -not -path \*meta_result_1.tbl -not -path \*.pheno.glm.logistic.hybrid -not -path \*test_run\*/\*  )



module load rclone

rclone sync results-20260415 box:Francis\ _Lab_Share/20250800-AGS-CIDR-ONCO-I370-TCGA/20260414d-GWAS-summary-stats/results-20260415 \
  --include "**/final/**" --include "**/logs/**" --include "**/phenotypes/**" --include "**/metal/**"

```



