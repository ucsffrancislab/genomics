
#	20240610-Stanford/20240610-cutadapt


```


cutadapt_array_wrapper.bash --threads 4 --extension _1.fastq.gz \
  --out ${PWD}/out \
  --trim-n --match-read-wildcards --times 4 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  -a "A{10}" -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
  -G "T{10}" -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
  /francislab/data1/raw/20240610-Stanford/fastq/*_1.fastq.gz




```



