
#	RepEnrich2

https://github.com/nerettilab/RepEnrich2

First actually try

Ignoring R2 other than UMI
Quality TRIMMING rather than FILTERING
Found bug in UMI processing




cat data/20200909-TARGET-ALL-P2-RNA_bam/20220309-RepEnrich2-test/README.md 


```
ln -s "/francislab/data1/raw/20220610-EV/Sample covariate file_ids and indexes_for QB3_NovSeq SP 150PE_SFHH011 S Francis_5-2-22hmh.csv" metadata.csv
```


```
mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%8 --job-name="RepEnrich2" --output="${PWD}/logs/RepEnrich2.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/RepEnrich2_array_wrapper.bash
```



```
./RepEnrich2_EdgeR_rmarkdown.bash
```



```
RepEnrich2_upload.bash
```

