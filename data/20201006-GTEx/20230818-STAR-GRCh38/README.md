
#	20201006-GTEx/20230818-STAR-GRCh38

1438 samples




```
STAR_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230817-cutadapt/out/SRR821*_R1.fastq.gz

```



