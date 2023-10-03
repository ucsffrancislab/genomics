
#	20201006-GTEx/20231002-STAR-HumanViral

1438 samples



```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/SRR10*_R1.fastq.gz


```


```
module load samtools
for b in out/*bam ; do s=$( basename $b .Aligned.sortedByCoord.out.bam ); c=$( samtools view -f66 $b NC_007605.1 | wc -l ) ; echo $s,$c; done
```


