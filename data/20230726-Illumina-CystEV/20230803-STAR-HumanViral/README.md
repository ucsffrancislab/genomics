
#	20230726-Illumina-CystEV/20230803-STAR-HumanViral




```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20230801 \
  --out ${PWD}/out \
  ${PWD}/../20230801-cutadapt/out/*_R1.fastq.gz

```



```
for bam in out/*bam ; do echo $bam ; samtools view -F14 $bam | head ; done
```

Nothing, but not surpising as is RNA


