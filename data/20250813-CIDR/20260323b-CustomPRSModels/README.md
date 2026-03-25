
#	20250813-CIDR/20260323b-CustomPRSModels


Redo the scores locally for CIDR cases and controls and include the seven custom models.

/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20260122-CustomPRSModels


Rerun the scoring for all 4 complete datasets for all models including these new 7.

```bash
for chrnum in {1..22} ; do
echo "pgs-calc.bash ${chrnum}"
done > commands

commands_array_wrapper.bash --array_file commands --time 2-0 --threads 8 --mem 60G --jobcount 8 --jobname pgs-calc
```


Merge after completes

```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-score \
  --export=None --output="${PWD}/pgs-merge-score.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-score ${PWD}/pgs-calc-scores/chr*.scores.txt --out ${PWD}/pgs-calc-scores/scores.txt"

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --job-name=pgs-merge-info \
  --export=None --output="${PWD}/pgs-merge-info.$( date "+%Y%m%d%H%M%S%N" ).out" \
  --time=1-0 --nodes=1 --ntasks=8 --mem=60G \
  --wrap="module load openjdk;java -Xmx50G -jar /francislab/data1/refs/Imputation/PGSCatalog/pgs-calc.jar merge-info ${PWD}/pgs-calc-scores/chr*.scores.info --out ${PWD}/pgs-calc-scores/scores.info"



scale_raw_pgs_scores_to_z-scores.py -i pgs-calc-scores/scores.txt -o pgs-calc-scores/scores.z-scores.txt

gzip pgs-calc-scores/scores.z-scores.txt

```









Now have to re-integrate with the others: I370, Onco and TCGA.

That will be done there though.

Probably a new subdir

/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/2026....-CustomPRSModels/







