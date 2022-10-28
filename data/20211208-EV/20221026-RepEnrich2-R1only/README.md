
#	RepEnrich2

https://github.com/nerettilab/RepEnrich2


```
ln -s /francislab/data1/raw/20211208-EV/plot_2.csv metadata.csv

```


```
mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-13%4 --job-name="RepEnrich2" --output="${PWD}/logs/RepEnrich2.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/RepEnrich2_array_wrapper.bash
```



```
./RepEnrich2_EdgeR_rmarkdown.bash
```



```
RepEnrich2_upload.bash
```

