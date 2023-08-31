

#	20200603-TCGA-GBMLGG-WGS/20230804-bowtie2-HumanViral




```
bowtie2_array_wrapper.bash --threads 8 --very-sensitive \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20230801 \
  --out ${PWD}/out \
  ${PWD}/../20230803-cutadapt/out/*_R1.fastq.gz

```



```
bowtie2_array_wrapper.bash --threads 8 --very-sensitive \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM \
  --out ${PWD}/out \
  ${PWD}/../20230803-cutadapt/out/*_R1.fastq.gz

```



```
samtools view -F14 out/02-2483-01A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam | awk '{OFS=","}(($3~/(chr|KI|GL)/&&$7~/(AC|NC)/)||($3~/(AC|NC)/&&$7~/(chr|KI|GL)/)){print $1,$5,$3,$7,$10}'



samtools view -F14 out/02-2483-01A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam | awk '{OFS=","}(($3~/(chr|KI|GL)/&&$7~/(AC|NC)/)||($3~/(AC|NC)/&&$7~/(chr|KI|GL)/))' | sort > out/02-2483-01A-01D-1494.GRCh38.primary_assembly.genome.plus.viral-20210916-RMHM.bam.discordant_alignments.all.sam &

```




```
for bam in out/*bam ; do echo $bam ; samtools view -F14 $bam | head ; done
```


