
#	20230628-Costello/20230629-cutadapt

Gonna write cutadapt_array_wrapper.bash



Then ...
-e 0.1 -q 20 -O 1 -a AGATCGGAAGAGC 

```

./cutadapt_array_wrapper.bash --threads 4 --extension _R1.fastq.gz \
  --out /francislab/data1/working/20230628-Costello/20230629-cutadapt/out \
--trim-n --match-read-wildcards --times 4 \
--error-rate 0.1 --overlap 5 \
-a "A{10}" -a "G{10}" \
-a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -a GGAAGAGCACACGTCTGAACTCCAGTCA -a ATCTCGTATGCCGTCTTCTGCTTG \
-A "T{10}" -A "C{10}" \
-A AGATCGGAAGAGCGTCGTGTAGGGAAAGAG    -A GGAAGAGCGTCGTGTAGGGAAAGAG    -A TGTAGATCTCGGTGGTCGCCGTATCATT \
--minimum-length 15 \
--quality-cutoff 25 \
  /francislab/data1/raw/20230628-Costello/fastq/p3*R1.fastq.gz

```




