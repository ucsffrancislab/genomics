
#	20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19

REDO


Recompute the full PGS catalog on the 4 dataset using hg19 imputation and R2 filter of 0.3

The UMich imputation (2.0.11) already included a Rsq filter of 0.3


```bash
mkdir input
cd input
ln -s /francislab/data1/working/20250813-CIDR/20260320f-impute_genotypes/imputed-umich-cidr
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-i370
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-onco
ln -s /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20251218-survival_gwas/imputed-umich-tcga
cd..

```


Rerun the scoring for all 4 complete datasets for all models including these new 7.

```bash
for data in cidr tcga i370 onco; do
for chrnum in {1..22} ; do
echo "pgs-calc.bash ${data} ${chrnum}"
done
done > commands

commands_array_wrapper.bash --array_file commands --time 14-0 --threads 8 --mem 60G --jobcount 8 --jobname pgs-calc
```








Merge after completes

```bash

outdir=/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260410-compute_PGS_hg19

for data in cidr i370 onco tcga; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-score-${data} \
  --export=None --output="${PWD}/pgs-merge-score-${data}.$( date "+%Y%m%d%H%M%S%N" ).log" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-score ${outdir}/pgs-calc-scores/${data}/chr*.scores.txt --out ${outdir}/pgs-calc-scores/${data}/scores.txt; chmod -w ${outdir}/pgs-calc-scores/${data}/scores.txt"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-info-${data} \
  --export=None --output="${PWD}/pgs-merge-info-${data}.$( date "+%Y%m%d%H%M%S%N" ).log" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-info ${outdir}/pgs-calc-scores/${data}/chr*.scores.info --out ${outdir}/pgs-calc-scores/${data}/scores.info; chmod -w ${outdir}/pgs-calc-scores/${data}/scores.info"

done
```




Scale the new raw scores matrix.

```bash

for data in cidr i370 onco tcga; do

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=scale-${data} \
  --export=None --output="${PWD}/scale-${data}.$( date "+%Y%m%d%H%M%S%N" ).log" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="scale_raw_pgs_scores_to_z-scores.py -i pgs-calc-scores/${data}/scores.txt -o pgs-calc-scores/${data}/scores.z-scores.txt; gzip pgs-calc-scores/${data}/scores.txt; gzip pgs-calc-scores/${data}/scores.z-scores.txt; chmod -w pgs-calc-scores/${data}/scores.z-scores.txt*"

done

```



```bash

cp /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260326-GWAS_summary_stats/*csv ./

```
