
#	REdiscoverTE


```
mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%8 --job-name="REdiscoverTE" --output="${PWD}/logs/REdiscoverTE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/REdiscoverTE_array_wrapper.bash


REdiscoverTE_rollup.bash






ssh d1
module load r
REdiscoverTE_rollup_merge.Rscript

for f in rollup/rollup.merged/* ; do
ln -s rollup.merged/$( basename ${f} ) rollup/$( basename ${f} )
done






ln -s /francislab/data1/raw/20211208-EV/plot_2.csv metadata.csv

#	edit and then
REdiscoverTE_EdgeR_rmarkdown.bash

scontrol update ArrayTaskThrottle=4 JobId=874115






REdiscoverTE_upload.bash

```



A problem running BioMart multiple times. I think that the cache is written to same place and they overwrite?


