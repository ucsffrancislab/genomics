
#	20230628-Costello/20230706-REdiscoverTE


568 samples


```

REdiscoverTE_array_wrapper.bash --paired \
  --out ${PWD}/out \
  --extension _R1.fastq.gz \
  ${PWD}/../20231004-cutadapt/out/*_R1.fastq.gz

```




```BASH

REdiscoverTE_rollup.bash \
--indir ${PWD}/out \
--datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation_noquestion \
--outbase ${PWD}/REdiscoverTE_rollup_noquestion

```

AFTER COMPLETION

```BASH

REdiscoverTE_rollup_merge.bash --outbase ${PWD}/REdiscoverTE_rollup_noquestion

```




Giving that this is a spatial analysis, this analysis doesn't seem appropriate.


Haven't run yet ...
```

REdiscoverTE_EdgeR_rmarkdown.bash

```



