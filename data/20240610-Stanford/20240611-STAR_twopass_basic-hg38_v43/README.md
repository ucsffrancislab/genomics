
#	20240610-Stanford/20240611-STAR_twopass_basic-hg38_v43


```

STAR_twopass_basic_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20240610-cutadapt/out/*_R1.fastq.gz

```



