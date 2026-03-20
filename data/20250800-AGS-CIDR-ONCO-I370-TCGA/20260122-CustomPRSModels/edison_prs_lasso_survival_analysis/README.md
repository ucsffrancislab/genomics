
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels/edison_prs_lasso_survival_analysis


```bash

for f in ~/github/ucsffrancislab/edison_prs_lasso_survival_analysis/*{sh,py}; do
ln -s $f
done


sbatch slurm_single_job.sh

```


```bash

box_upload.bash results/results_summary.json results/*/*

```


Challenge Edison on it running it

Run the tests




##	20260312 - New settings


```bash

sbatch slurm_single_job.sh


mkdir run3-new_params
mv prs_lasso* results/ run3-new_params/
box_upload.bash run3-new_params/prs_lasso* run3-new_params/results/*/*

```



Limit the models and see what happens

```bash

awk -F, '($6 >= 0.5){print $1}'  ../scores.coverage.matrix.csv > model_list.txt


sbatch slurm_single_job.sh . results --models model_list.txt 


mkdir run4-limit_models
mv prs_lasso* results/ run4-limit_models
box_upload.bash run4-limit_models/prs_lasso* run4-limit_models/results/*/*

```




Limit the models and see what happens
Show some baseline c-indexes

```bash

sbatch slurm_single_job.sh . results --models model_list.txt 


outdir=run5-limit_models_plus_baselines
mkdir ${outdir}
mv prs_lasso* results/ ${outdir}
box_upload.bash ${outdir}/prs_lasso* ${outdir}/results/results_summary.json ${outdir}/results/*/*

```



Include Claude's 2 other mods

Limit the models and see what happens
Show some baseline c-indexes

```bash

sbatch slurm_single_job.sh . results --models model_list.txt 


outdir=run6-limit_models_plus_baselines_and_mods
mkdir ${outdir}
mv prs_lasso* results/ ${outdir}
box_upload.bash ${outdir}/prs_lasso* ${outdir}/results/results_summary.json ${outdir}/results/*/*

```



Include Claude's LOCO strategy code

```bash

sbatch slurm_single_job.sh . results --models model_list.txt 

outdir=run7-LOCO
mkdir ${outdir}
mv prs_lasso* results/ ${outdir}
box_upload.bash ${outdir}/prs_lasso* ${outdir}/results/results_summary.json ${outdir}/results/loco_folds/*/*/*

python3 summarize_loco_pgs.py --results-dir ${outdir}/results > ${outdir}/summary.txt
box_upload.bash ${outdir}/summary.txt ${outdir}/results/loco_folds/pgs*.csv


```





##	20260316 - Testing random split strategy




```bash

outdir=run8-random_test
sbatch slurm_single_job.sh . ${outdir} --models model_list.txt --n-models 100 --cv-strategy random_split

outdir=run8-loco_test
sbatch slurm_single_job.sh . ${outdir} --models model_list.txt --n-models 100 --cv-strategy loco



outdir=run9-random_test
sbatch slurm_single_job.sh . ${outdir} --models model_list.txt --n-models 100 --cv-strategy random_split

outdir=run9-loco_test
sbatch slurm_single_job.sh . ${outdir} --models model_list.txt --n-models 100 --cv-strategy loco





outdir=run9-random_test

mv prs_lasso* ${outdir}
box_upload.bash ${outdir}/prs_lasso* ${outdir}/results_summary.json ${outdir}/random_splits/*csv ${outdir}/random_splits/split_*/*/*




outdir=run9-random_full
sbatch slurm_single_job.sh . ${outdir} --models model_list.txt --cv-strategy random_split


outdir=run9-random_full

mv prs_lasso* ${outdir}

./generate_report.py --results-dir ${outdir} --output ${outdir}/report.html
box_upload.bash ${outdir}/prs_lasso* ${outdir}/report.html ${outdir}/results_summary.json ${outdir}/random_splits/*csv ${outdir}/random_splits/split_*/*/*



```






##	20260317

```bash

echo "model" > brain_models.txt
grep -E "Brain|Glioma" /francislab/data1/refs/Imputation/PGSCatalog/metadata/pgs_all_metadata_scores.csv | cut -d, -f1 >> brain_models.txt
echo "allGlioma_scoring_system" >> brain_models.txt
echo "gbm_scoring_system" >> brain_models.txt
echo "nonGbm_scoring_system" >> brain_models.txt
echo "idhmut_1p19qcodel_scoring_system" >> brain_models.txt
echo "idhmut_1p19qnoncodel_scoring_system" >> brain_models.txt
echo "idhmut_scoring_system" >> brain_models.txt
echo "idhwt_scoring_system" >> brain_models.txt




For the the brain PGS, lets do CIDR and random splits.

outdir=run10-random_brain
sbatch slurm_single_job.sh . ${outdir} --models brain_models.txt --cv-strategy random_split
mv prs_lasso_1079230* ${outdir}

outdir=run10-random_brain
box_upload.bash ${outdir}/prs_lasso* ${outdir}/report.html ${outdir}/results_summary.json ${outdir}/random_splits/*csv ${outdir}/random_splits/split_*/*/*


outdir=run10-fixed_brain
sbatch slurm_single_job.sh . ${outdir} --models brain_models.txt --cv-strategy fixed
mv prs_lasso_1079233* ${outdir}

outdir=run10-fixed_brain
box_upload.bash ${outdir}/prs_lasso* ${outdir}/report.html ${outdir}/results_summary.json ${outdir}/prs_lasso* ${outdir}/*/*

```


##	20260318 - pipeline testing

```bash

for cv in random_split loco fixed ; do
echo $cv
outdir=run11-${cv}_test
mkdir ${outdir}
sbatch --job-name=${cv} --output=${outdir}/prs_lasso_%j.out.txt --error=${outdir}/prs_lasso_%j.err.txt --cpus-per-task=16 --mem=120G slurm_single_job.sh . ${outdir} --test --cv-strategy ${cv}
done


outdir=run11-random_split_test
box_upload.bash ${outdir}/prs_lasso* ${outdir}/report.html ${outdir}/results_summary.json ${outdir}/random_splits/*csv ${outdir}/random_splits/split_*/*/*

outdir=run11-loco_test
box_upload.bash ${outdir}/prs_lasso* ${outdir}/report.html ${outdir}/results_summary.json ${outdir}/loco_folds/*/*/*  ${outdir}/loco_folds/pgs*.csv

outdir=run11-fixed_test
box_upload.bash ${outdir}/prs_lasso* ${outdir}/report.html ${outdir}/results_summary.json ${outdir}/*/*
```




