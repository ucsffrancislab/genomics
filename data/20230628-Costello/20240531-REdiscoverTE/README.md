
#	20230628-Costello/20230706-REdiscoverTE


568 samples


```

REdiscoverTE_array_wrapper.bash --paired \
  --out ${PWD}/out \
  --extension _R1.fastq.gz \
  ${PWD}/../20231004-cutadapt/out/*_R1.fastq.gz


REdiscoverTE_array_wrapper.bash --paired \
  --array 413-568 --time 1-0 \
  --out ${PWD}/out \
  --extension _R1.fastq.gz \
  ${PWD}/../20231004-cutadapt/out/*_R1.fastq.gz



```




```BASH

REdiscoverTE_rollup.bash \
--indir ${PWD}/out \
--datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation.noquestion \
--outbase ${PWD}/REdiscoverTE_rollup.noquestion

```

AFTER COMPLETION

```BASH

REdiscoverTE_rollup_merge.bash --outbase ${PWD}/REdiscoverTE_rollup.noquestion

```




Giving that this is a spatial analysis, this analysis doesn't seem appropriate.


Haven't run yet ...
```

REdiscoverTE_EdgeR_rmarkdown.bash

```



