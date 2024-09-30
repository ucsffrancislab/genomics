
#	20240925-Illumina-PhIP/20240925b-bowtie2



```

bowtie2_array_wrapper.bash --single --threads 8 --sort --very-sensitive \
  --norc --extension .fastq.gz --outdir ${PWD}/out \
  -x /francislab/data1/refs/PhIP-Seq/VIR3_clean.1-160 \
  ${PWD}/../20240925a-cutadapt/out/*fastq.gz

```


```
head -1 /francislab/data1/raw/20240925-Illumina-PhIP/manifest.csv | tr , "\n"
Library
Sample
Item NO
IDNO
LabNO
condition
BSA blocked plate
Protein A/G beads (uL)
Phage Library 
Index
Sequence
Qubit Concentration(ng/uL)
pool volume(uL)
Total amount(ng)
```


```

./report.bash > report.csv

```



