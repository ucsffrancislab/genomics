
#	20250409-Illumina-PhIP/20250409b-bowtie2



```

bowtie2_array_wrapper.bash --single --threads 8 --sort --very-sensitive \
  --norc --extension .fastq.gz --outdir ${PWD}/out \
  -x /francislab/data1/refs/PhIP-Seq/VIR3_clean.1-84 \
  ${PWD}/../20250409a-cutadapt/out/*fastq.gz

```




```

./report.bash > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report*csv


sort -t, -k2,2 /francislab/data1/raw/20250409-Illumina-PhIP/sample_s_number.csv | grep -vs "Undetermined" | sed '1isample,s' > sample_s_number.csv

head -1 report.t.csv > tmp1.csv
tail -n +2 report.t.csv | sort -t, -k1,1 >> tmp1.csv

join --header -t, -1 2 -2 1 sample_s_number.csv tmp1.csv > tmp2.csv
mv tmp2.csv report.t.csv
cat report.t.csv | datamash transpose -t, > report.csv 
box_upload.bash report*csv

```


```
./tile_counts.Rmd
box_upload.bash tile_counts.html 

```
