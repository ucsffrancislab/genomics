


#	20230726-Illumina-CystEV/20230801-STAR


```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230801-cutadapt/out/*_R1.fastq.gz

```

