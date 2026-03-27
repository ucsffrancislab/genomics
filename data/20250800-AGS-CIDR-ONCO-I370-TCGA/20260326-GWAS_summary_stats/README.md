
# 20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats

Developed a GWAS summary stats pipeline

https://claude.ai/chat/1ff6d67a-f2ea-4a29-9cdf-39a5c758c43c




```bash

~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline/run_pipeline.sh -h

```


```bash

DIR=~/github/ucsffrancislab/Claude-Multi-Array-Glioma-GWAS-Meta-Analysis-Pipeline

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=test_run --ntasks=1 --cpus-per-task=8 --mem=60G \
 ${DIR}/run_pipeline.sh --pipeline-dir ${DIR} \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --test --outdir results/test_run 



sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=all --ntasks=1 --cpus-per-task=8 --mem=60G \
 ${DIR}/run_pipeline.sh --pipeline-dir ${DIR} \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir results/all_glioma 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhwt --ntasks=1 --cpus-per-task=8 --mem=60G \
 ${DIR}/run_pipeline.sh --pipeline-dir ${DIR} \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir results/idhwt --idh-subtype wt 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhmt --ntasks=1 --cpus-per-task=8 --mem=60G \
 ${DIR}/run_pipeline.sh --pipeline-dir ${DIR} \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir results/idhmt --idh-subtype mt

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhmtcodel --ntasks=1 --cpus-per-task=8 --mem=60G \
 ${DIR}/run_pipeline.sh --pipeline-dir ${DIR} \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir results/idhmt_codel --idh-subtype mt --pq-subtype codel 

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
 --job-name=idhmtintact --ntasks=1 --cpus-per-task=8 --mem=60G \
 ${DIR}/run_pipeline.sh --pipeline-dir ${DIR} \
 --datasets-config ${PWD}/datasets.tsv \
 --r2-threshold 0.8 --outdir results/idhmt_intact --idh-subtype mt --pq-subtype intact


```

