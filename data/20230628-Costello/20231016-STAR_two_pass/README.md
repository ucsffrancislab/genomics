
#	20230628-Costello/20231016-STAR_two_pass

This is just a test of the pipeline on a small RNA dataset.


```
STAR_two_pass_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20231004-cutadapt/out/*_R1.fastq.gz

```


