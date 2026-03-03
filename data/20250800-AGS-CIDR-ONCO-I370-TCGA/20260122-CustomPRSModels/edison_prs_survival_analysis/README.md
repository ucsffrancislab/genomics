
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_survival_analysis


```bash

for f in ~/github/ucsffrancislab/edison_prs_survival_analysis/*{sh,py}; do
ln -s $f
done

python3 create_model_list.py \
    --scores cidr.scores.z-scores.txt.gz \
    --output model_list.txt \

sbatch run_parallel_survival.sh 

```
