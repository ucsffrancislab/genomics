
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




---


##	20260330

```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=all --ntasks=1 --cpus-per-task=64 --mem=490G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir 20260330a-results/all_glioma 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --time=14-0 --export=None \
 --job-name=all --ntasks=1 --cpus-per-task=64 --mem=490G \
 --wrap="python3 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/scripts/09_known_loci.py \
    --params 20260330a-results/all_glioma/logs/params.tsv \
    --final-dir 20260330a-results/all_glioma/final \
    --known-loci ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/config/known_glioma_loci.tsv \
    --genome-build hg38 \
    --outdir 20260330a-results/all_glioma/final/plots"

box_upload.bash 20260330a-results/all_glioma/final/*tsv* 20260330a-results/all_glioma/final/plots/*




sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhwt --ntasks=1 --cpus-per-task=16 --mem=120G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir 20260330a-results/idhwt --idh-subtype wt 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhmt --ntasks=1 --cpus-per-task=16 --mem=120G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir 20260330a-results/idhmt --idh-subtype mt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhmtcodel --ntasks=1 --cpus-per-task=16 --mem=120G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir 20260330a-results/idhmt_codel --idh-subtype mt --pq-subtype codel 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhmtintact --ntasks=1 --cpus-per-task=16 --mem=120G \
 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir 20260330a-results/idhmt_intact --idh-subtype mt --pq-subtype intact

```


```bash

box_upload.bash 20260330a-results/id*/final/*{v,z} 20260330a-results/id*/final/plots/*


box_upload.bash 20260330a-results/{idhmt_intact,idhmt,idhwt}/final/*{v,z} 20260330a-results/{idhmt_intact,idhmt,idhwt}/final/plots/*
```












```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=cross --ntasks=1 --cpus-per-task=64 --mem=490G \
 --wrap="python3 ~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/scripts/10_cross_subtype.py \
    --result-dirs 20260330a-results/all_glioma \
                  20260330a-results/idhwt \
                  20260330a-results/idhmt \
                  20260330a-results/idhmt_intact \
                  20260330a-results/idhmt_codel \
    --outdir 20260330a-results/cross_subtype"
```


