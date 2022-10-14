
#	TEtranscripts

https://github.com/mhammell-laboratory/TEtranscripts

First actually try

Ignoring R2 other than UMI
Quality TRIMMING rather than FILTERING
Found bug in UMI processing




cat data/20200909-TARGET-ALL-P2-RNA_bam/20220302-TEtranscripts-test/README.md 


```
ln -s /francislab/data1/raw/20211208-EV/plot_2.csv
```



```

mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="TEtranscripts" --output="${PWD}/logs/TEtranscripts.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/TEtranscripts_array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083

```


```
./TEtranscripts_DESeq2_rmarkdown.bash
```







