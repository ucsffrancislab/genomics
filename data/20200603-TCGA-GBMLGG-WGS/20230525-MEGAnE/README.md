
#	20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE


/francislab/data1/refs/MEGAnE



```

MEGAnE_array_wrapper.bash --threads 8 --extension .bam \
--in /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230124-hg38-bwa/out \
--out /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/out

```



```

MEGAnE_aggregation_steps.bash --threads 64 \
--in  /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/out \
--out /francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20230525-MEGAnE/aggregation

```




