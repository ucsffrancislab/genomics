
#	20230726-Illumina-CystEV/20230809-preprocess


So wrong adapters in 20230801-cutadapt
And we have a UMI which I didn't deal with



Continue Format filter? Yes. 18+GTT - keep a count
Where is the UMI? Beginning of R2?
Use UMI and deduplicate or just trim and ignore? dedup
Deup and preserve unaligned? Ignore unaligned for now.
Viral discover on cyst fluid samples only?
Create model for old and new cyst fluid only and test on serum.
Trim precede TTTTTTT on R2?
Create report



```

EV_preprocessing_array_wrapper.bash --threads 8 --out ${PWD}/out --extension _R1.fastq.gz \
  /francislab/data1/raw/20230726-Illumina-CystEV/fastq/*R1.fastq.gz


```




```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv

```







