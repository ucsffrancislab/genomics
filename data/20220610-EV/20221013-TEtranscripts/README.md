
#	TEtranscripts

https://github.com/mhammell-laboratory/TEtranscripts

First actually try

Ignoring R2 other than UMI
Quality TRIMMING rather than FILTERING
Found bug in UMI processing




cat data/20200909-TARGET-ALL-P2-RNA_bam/20220302-TEtranscripts-test/README.md 


```
ln -s "/francislab/data1/raw/20220610-EV/Sample covariate file_ids and indexes_for QB3_NovSeq SP 150PE_SFHH011 S Francis_5-2-22hmh.csv" metadata.csv
```


From https://github.com/mhammell-laboratory/TEtranscripts/issues/54

```
Thank you for the suggestions.

Regarding multi-threading, we typically use TEcount to quantify each sample (and thus send a single library to each node), and then merge the outputs into a single count table before running DESeq2 aftewards. This might be a useful approach if you have lots of replicates to quantify for a single differential analysis.

Although we mentioned the memory requirements in the associated publication, we agree that it might require some updates (as libraries are getting bigger), and should also be in the README for ease of access.
```

also

```
TEcount is better suited than TEtranscripts for usage in the cluster environment, as each sample (e.g. replicates of an experiment) can be quantified on separate nodes. The output can then be merged into a single count table for differential analysis. In our experience, we recommend around 20-30Gb of memory for analyzing human samples (hg19) with around 20-30 million mapped reads when running on a cluster.

```
So don't use TEtranscripts command? Use TEcounts and then analyze after.



```

mkdir -p ${PWD}/logs
date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --array=1-86%1 --job-name="TEtranscripts" --output="${PWD}/logs/TEtranscripts.${date}-%A_%a.out" --time=4320 --nodes=1 --ntasks=8 --mem=60G --gres=scratch:250G ${PWD}/TEtranscripts_array_wrapper.bash


scontrol update ArrayTaskThrottle=6 JobId=352083

```






Merge cntTables



Run DESEQ analysis







