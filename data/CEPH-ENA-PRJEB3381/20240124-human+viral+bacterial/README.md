
#	CEPH-ENA-PRJEB3381/20240124-human+viral+bacterial


Align these samples to my new human+viral+bacterial reference 


```
/c4/home/gwendt/.local/bin/bowtie2_array_wrapper.bash --sort --extension _1.fastq.gz --very-sensitive --threads 16 \
-x /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.viral-20230801.bacteria-20210916-NC_only \
--outdir /francislab/data1/working/CEPH-ENA-PRJEB3381/20240124-human+viral+bacterial/out-e2e \
/francislab/data1/raw/CEPH-ENA-PRJEB3381/*_1.fastq.gz

```

```
/c4/home/gwendt/.local/bin/bowtie2_array_wrapper.bash --sort --extension _1.fastq.gz --very-sensitive-local --threads 32 \
-x /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome.viral-20230801.bacteria-20210916-NC_only \
--outdir /francislab/data1/working/CEPH-ENA-PRJEB3381/20240124-human+viral+bacterial/out-loc \
/francislab/data1/raw/CEPH-ENA-PRJEB3381/*_1.fastq.gz

```
