
#	20250822-Illumina-PhIP/20250822a-cutadapt


```
cutadapt_array_wrapper.bash --single --threads 4 --extension .fastq.gz \
  --out ${PWD}/out \
  --trim-n --match-read-wildcards --times 4 \
  --error-rate 0.1 --overlap 5 --minimum-length 50 --quality-cutoff 25 \
  -a "A{10}" -a ACACTCTTTCCCTACACGACTCCAGTCAGGTGTGATGCTC \
  /francislab/data1/raw/20250822-Illumina-PhIP/fastq/S*.fastq.gz

#  -a "A{10}" -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
#  -G "T{10}" -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \

```

I'm not finding any adapters.

I'm not sure if this is the correct one.




Fri Aug 22 10:57:01 PDT 2025
Preparing array job :20250822105701592643524:
Unknown param :.fastq.gz: Not a file. Passing to job.
Unknown param :/francislab/data1/working/20250822-Illumina-PhIP/20250822a-cutadapt/out: Not a file. Passing to job.
Unknown param :4: Not a file. Passing to job.
Unknown param :0.1: Not a file. Passing to job.
Unknown param :5: Not a file. Passing to job.
Unknown param :50: Not a file. Passing to job.
Unknown param :25: Not a file. Passing to job.
Unknown param :A{10}: Not a file. Passing to job.
Unknown param :ACACTCTTTCCCTACACGACTCCAGTCAGGTGTGATGCTC: Not a file. Passing to job.
Unknown param :/francislab/data1/raw/20250822-Illumina-PhIP/fastq/S0.fastq.gz: Assuming file

