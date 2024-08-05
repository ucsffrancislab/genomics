

#	20240802-Illumina-PhIP/20240803-bowtie2



```

bowtie2_array_wrapper.bash --single --threads 8 --sort --very-sensitive \
  --norc --extension .fastq.gz --outdir ${PWD}/out \
  -x /francislab/data1/refs/PhIP-Seq/VIR3_clean.1-160 \
  ${PWD}/../20240802-cutadapt/out/*fastq.gz



```


