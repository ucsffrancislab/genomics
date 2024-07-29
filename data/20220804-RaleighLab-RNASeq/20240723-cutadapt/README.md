
#	20220804-RaleighLab-RNASeq/20240723-cutadapt

QM238 raw files are corrupt

301 paired end samples


```

cutadapt_array_wrapper.bash --threads 4 --extension _trimmed.1.fastq.gz \
  --out ${PWD}/out \
  --trim-n --match-read-wildcards --times 6 \
  --error-rate 0.1 --overlap 5 --minimum-length 15 --quality-cutoff 25 \
  -a "A{10}" -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
             -a AGATCGGAAGAGCACACGTCTGA \
             -a      GGAAGAGCACACGTCTGAACTCC \
             -a           AGCACACGTCTGAACTCCAGTCA \
             -a ATCTCGTATGCCGTCTTCTGCTTG \
  -G "T{10}" -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
             -A AGATCGGAAGAGCGTCGTGTAGG \
             -A      GGAAGAGCGTCGTGTAGGGAAAG \
             -A           AGCGTCGTGTAGGGAAAGAGTGT \
             -A GTGTAGATCTCGGTGGTCGCCGTATCATT \
  /francislab/data1/raw/20220804-RaleighLab-RNASeq/20240723/*_trimmed.1.fastq.gz

```


