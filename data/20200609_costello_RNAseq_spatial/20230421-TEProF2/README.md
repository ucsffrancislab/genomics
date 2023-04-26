
#	First run of TEProF2

/francislab/data1/refs/sources/gencodegenes.org/

/francislab/data1/refs/sources/genome.ucsc.edu/




Running this 3 different ways: unstranded, rf and fr for comparison

RseQC says that this data is --rf (fr-firststrand)





```

TEProF2_array_wrapper.bash --threads 4 --strand --rf \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out-rf \
  --extension .STAR.hg38.Aligned.out.bam

```


```

TEProF2_aggregation_steps.bash --threads 64 --strand --rf --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out-rf

```


---


```

TEProF2_array_wrapper.bash --threads 4 --strand --fr \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out-fr \
  --extension .STAR.hg38.Aligned.out.bam

```


```

TEProF2_aggregation_steps.bash --threads 64 --strand --fr --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out-fr

```

---


```

TEProF2_array_wrapper.bash --threads 4 \
  --in /francislab/data1/working/20200609_costello_RNAseq_spatial/20200615-STAR_hg38/out \
  --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out \
  --extension .STAR.hg38.Aligned.out.bam

```


```

TEProF2_aggregation_steps.bash --threads 64 --out /francislab/data1/working/20200609_costello_RNAseq_spatial/20230421-TEProF2/out

```

