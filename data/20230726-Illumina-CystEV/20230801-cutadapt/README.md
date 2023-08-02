
#	20230726-Illumina-CystEV/20230801-cutadapt



```

cutadapt_array_wrapper.bash --threads 4 --extension _R1.fastq.gz \
  --out ${PWD}/out \
  --trim-n --match-read-wildcards --times 7 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  -a "A{10}" -a "G{10}" -a "T{10}" -a "C{10}" \
  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG \
  -A "A{10}" -A "G{10}" -A "T{10}" -A "C{10}" \
  -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG    -A GGAAGAGCGTCGTGTAGGGAAAGAG    -A TGTAGATCTCGGTGGTCGCCGTATCATT \
  /francislab/data1/raw/20230726-Illumina-CystEV/fastq/*R1.fastq.gz

```



