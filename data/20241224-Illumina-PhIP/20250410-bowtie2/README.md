
#	20241224-Illumina-PhIP/20250410-bowtie2



```
bowtie2_array_wrapper.bash --single --threads 8 --sort --very-sensitive \
  --norc --extension .fastq.gz --outdir ${PWD}/out \
  -x /francislab/data1/refs/PhIP-Seq/VirScan/VIR3_clean.id_upper_oligo.uniq.1-80 \
  ${PWD}/../20241224a-cutadapt/out/*fastq.gz
```


```
./report.bash > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report*csv
```


```
module load r
./tile_counts.Rmd
box_upload.bash tile_counts.html 
```

