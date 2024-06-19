
#	20200720-TCGA-GBMLGG-RNA_bam/20240619-STAR_twopass_basic-hg38_v25


Aligning to an older reference to better compare to TEProF2's published results.

Not sure if this will have any impact.



```

STAR_twopass_basic_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_25/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```


