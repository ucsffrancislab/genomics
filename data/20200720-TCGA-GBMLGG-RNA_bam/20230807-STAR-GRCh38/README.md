
#	20200720-TCGA-GBMLGG-RNA_bam/20230807-STAR-GRCh38


```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230807-cutadapt/out/02*_R1.fastq.gz


```



