
#	20241204-Illumina-PhIP/20241204b-bowtie2



```

bowtie2_array_wrapper.bash --single --threads 8 --sort --very-sensitive \
  --norc --extension .fastq.gz --outdir ${PWD}/out \
  -x /francislab/data1/refs/PhIP-Seq/VIR3_clean.1-84 \
  ${PWD}/../20241204a-cutadapt/out/*fastq.gz

```




```

./report.bash > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report*csv


```



