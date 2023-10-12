
#	20201006-GTEx/20231002-STAR-HumanViral

1438 samples


```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/SRR*_R1.fastq.gz
```


```
module load samtools
for b in out/*bam ; do s=$( basename $b .Aligned.sortedByCoord.out.bam ); c=$( samtools view -f66 $b NC_007605.1 | wc -l ) ; echo $s,$c; done
```



##	20231011


Checking for any chimeric aligned pairs.

```
for bam in out/SRR*bam ; do 
echo $bam
samtools view -c -F14 ${bam}
done
```

NOTHING!



Several failed due to memory

```
grep -l "not enough mem" logs/STAR_array_wrapper.bash.* | awk -F_ '{print $NF}' | awk -F. '{print $1}' | sort -n | paste -sd,
288,723,761,1049,1050,1051,1052,1053,1054
```

```
STAR_array_wrapper.bash --threads 16 \
  --array 288,723,761,1049,1050,1051,1052,1053,1054 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/SRR*_R1.fastq.gz
```






