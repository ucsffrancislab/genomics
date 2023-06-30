
#	20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS


Prior STAR alignment did not include the XS tag which may be needed by TEProF2 (stringtie)

```

STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a \
  --out /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230628-STAR_hg38_XS/out \
  /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/*_R1.fastq.gz

```



