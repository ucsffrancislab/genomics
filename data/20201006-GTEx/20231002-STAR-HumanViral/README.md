
#	20201006-GTEx/20231002-STAR-HumanViral

1438 samples



```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/SRR10*_R1.fastq.gz


```




```
samtools view -f66 out/SRR1069188.Aligned.sortedByCoord.out.bam NC_007605.1 | wc -l
```



