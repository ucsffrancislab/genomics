
#	REdiscoverTE


```
ln -s "/francislab/data1/raw/20220610-EV/Sample covariate file_ids and indexes_for QB3_NovSeq SP 150PE_SFHH011 S Francis_5-2-22hmh.csv" metadata.csv



mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="REdiscoverTE" --output="${PWD}/logs/REdiscoverTE.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/REdiscoverTE_array_wrapper.bash


REdiscoverTE_rollup.bash



#	for larger sample count ...
ssh d1
module load r
REdiscoverTE_rollup_merge.Rscript
#	otherwise ...
ln -s rollup.00 rollup/rollup.merged 



for f in rollup/rollup.merged/* ; do
ln -s rollup.merged/$( basename ${f} ) rollup/$( basename ${f} )
done



#	edit and then
REdiscoverTE_EdgeR_rmarkdown.bash

scontrol update ArrayTaskThrottle=4 JobId=874115






upload.bash
```



A problem running BioMart multiple times. I think that the cache is written to same place and they overwrite?






sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --array=1-72%1 --job-name=rmarkdown --output=/francislab/data1/working/20220610-EV/20221003-REdiscoverTE/logs/REdiscoverTE.20221004073909277766416.rmarkdown.%A_%a.out --time=1440 --nodes=1 --ntasks=8 --mem=60G /francislab/data1/working/20220610-EV/20221003-REdiscoverTE/REdiscoverTE_EdgeR_rmarkdown.bash




