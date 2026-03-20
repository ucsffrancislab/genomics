
#	20250813-CIDR/20260320a-liftover_to_hg19


This built-in liftover from the imputation server utils allows many more to pass. Not sure if this is good or bad.
Takes about 5 minutes.


```bash

sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --time 1-0 --nodes=1 --ntasks=16 --mem=120G --export=None \
 --job-name=plink_liftover --out=${PWD}/plink_liftover.out \
 plink_liftover_hg38_to_hg19.bash /francislab/data1/raw/20250813-CIDR/CIDR ${PWD}/work

```




