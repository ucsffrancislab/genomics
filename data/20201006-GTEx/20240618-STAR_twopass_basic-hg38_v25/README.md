
#	20201006-GTEx/20240618-STAR_twopass_basic-hg38_v25


1438 samples


```

STAR_twopass_basic_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_25/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/*_R1.fastq.gz

```


