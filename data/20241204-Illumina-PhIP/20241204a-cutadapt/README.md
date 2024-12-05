
#	20241204-Illumina-PhIP/20241204a-cutadapt


```
cutadapt_array_wrapper.bash --single --threads 4 --extension .fastq.gz \
  --out ${PWD}/out \
  --trim-n --match-read-wildcards --times 4 \
  --error-rate 0.1 --overlap 5 --minimum-length 50 --quality-cutoff 25 \
  -a "A{10}" -a ACACTCTTTCCCTACACGACTCCAGTCAGGTGTGATGCTC \
  /francislab/data1/raw/20241204-Illumina-PhIP/fastq/S*.fastq.gz

#  -a "A{10}" -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
#  -G "T{10}" -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \

```

I'm not finding any adapters.

I'm not sure if this is the correct one.

