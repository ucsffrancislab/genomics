
#	REdiscoverTE


```
ln -s "/francislab/data1/raw/20220610-EV/Sample covariate file_ids and indexes_for QB3_NovSeq SP 150PE_SFHH011 S Francis_5-2-22hmh.csv" metadata.csv



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="REdiscoverTE" --output="${PWD}/logs/REdiscoverTE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/REdiscoverTE_array_wrapper.bash


REdiscoverTE_rollup.bash


REdiscoverTE_rollup_merge.Rscript
ln -s rollup.00 rollup/rollup.merged 
for f in rollup/rollup.merged/* ; do
ln -s rollup.merged/$( basename ${f} ) rollup/$( basename ${f} )
done


upload.bash
```


