
#	20200720-TCGA-GBMLGG-RNA_bam/20240721-REdiscoverTE-k31

895 total files


##	Complete Run


```BASH

REdiscoverTE_array_wrapper.bash --paired -k 31 \
  --out ${PWD}/out \
  --extension _R1.fastq.gz \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```

```BASH

REdiscoverTE_rollup.bash -k 31 \
--indir ${PWD}/out \
--datadir /francislab/data1/refs/REdiscoverTE/rollup_annotation_noquestion \
--outbase ${PWD}/REdiscoverTE_rollup_noquestion

```

AFTER COMPLETION

```BASH

REdiscoverTE_rollup_merge.bash --outbase ${PWD}/REdiscoverTE_rollup_noquestion

```

```BASH

#	REdiscoverTE_EdgeR_rmarkdown.bash

```


