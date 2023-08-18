
#	20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt


```
ll ${PWD}/../20200803-bamtofastq/out/*_R1.fastq.gz | wc -l
895
```


This is a bit aggressive with all of the polys, but gonna see where it goes.


```

cutadapt_array_wrapper.bash --threads 4 --extension _R1.fastq.gz \
  --out ${PWD}/out \
  --trim-n --match-read-wildcards --times 7 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  -a "A{10}" -a "G{10}" -a "T{10}" -a "C{10}" \
  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG \
  -A "A{10}" -A "G{10}" -A "T{10}" -A "C{10}" \
  -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG    -A GGAAGAGCGTCGTGTAGGGAAAGAG    -A TGTAGATCTCGGTGGTCGCCGTATCATT \
  ${PWD}/../20200803-bamtofastq/out/*_R1.fastq.gz

```

Redo a little less aggressive


```

cutadapt_array_wrapper.bash --threads 4 --extension _R1.fastq.gz \
  --out ${PWD}/out \
  --trim-n --match-read-wildcards --times 4 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  -a "A{10}" -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
  -G "T{10}" -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
  ${PWD}/../20200803-bamtofastq/out/*_R1.fastq.gz

```

