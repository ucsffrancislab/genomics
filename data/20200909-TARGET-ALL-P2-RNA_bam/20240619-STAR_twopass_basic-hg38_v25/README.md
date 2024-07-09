
#	20200909-TARGET-ALL-P2-RNA_bam/20240619-STAR_twopass_basic-hg38_v25


532 samples


```

STAR_twopass_basic_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_25/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20240618-cutadapt/out/*_R1.fastq.gz

```


Many need more memory



