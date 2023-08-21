
#	20201006-GTEx/20230817-cutadapt


```
ll /francislab/data1/raw/20201006-GTEx/fastq/*_R1.fastq.gz | wc -l
1438
```


This is a bit aggressive with all of the polys, but gonna see where it goes.


```

cutadapt_array_wrapper.bash --threads 4 --extension _R1.fastq.gz \
  --out ${PWD}/out \
  --trim-n --match-read-wildcards --times 4 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  -a "A{10}" -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
  -G "T{10}" -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
  /francislab/data1/raw/20201006-GTEx/fastq/*_R1.fastq.gz


```



```

./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
cat report.csv | datamash transpose -t, > report.t.csv

```

