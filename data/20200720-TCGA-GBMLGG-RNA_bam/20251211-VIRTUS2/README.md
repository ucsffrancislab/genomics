
#	20200720-TCGA-GBMLGG-RNA_bam/20251211-VIRTUS2



/francislab/data1/refs/VIRTUS2/

```bash

for r1 in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt/out/*_R1.fastq.gz ; do
 r2=${r1/R1.fastq/R2.fastq}

 base=$( basename ${r1} _R1.fastq.gz )
 mkdir -p ${PWD}/out/${base}/

 echo "cd ${PWD}/out/${base}/; \
  export CWL_SINGULARITY_CACHE=/francislab/data1/refs/VIRTUS2/; \
  cwltool --singularity ~/github/yyoshiaki/VIRTUS2/bin/VIRTUS.PE.cwl \
   --fastq1 ${r1} --fastq2 ${r2} \
   --genomeDir_human /francislab/data1/refs/VIRTUS2/STAR_index_human \
   --genomeDir_virus /francislab/data1/refs/VIRTUS2/STAR_index_virus \
   --outFileNamePrefix_human human \
   --nthreads 8"

done > commands

commands_array_wrapper.bash --jobname VIRTUS2 --array_file commands --time 1-0 --threads 8 --mem 60G

```




Only useful if multiple groups to compare and if enough viral threshold surpassed.


```bash
for r1 in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20230807-cutadapt/out/*_R1.fastq.gz ; do
 base=$( basename ${r1} _R1.fastq.gz )
 echo ${base},${base},PE,case
done > out/input.csv

sed -i '1iName,Fastq,Layout,Group' out/input.csv
```

```bash
cd out; ~/github/yyoshiaki/VIRTUS2/wrapper/VIRTUS_wrapper.py input.csv \
  --VIRTUS ~/github/yyoshiaki/VIRTUS2/ --fastq --figsize 3,3 \
  --singularity -s1 _R1.fastq.gz -s2 _R2.fastq.gz \
  --outFileNamePrefix_human human \
  --genomeDir_human /francislab/data1/refs/VIRTUS2/STAR_index_human \
  --genomeDir_virus /francislab/data1/refs/VIRTUS2/STAR_index_virus
```

