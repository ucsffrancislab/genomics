
#	20211001-EV/20231010-STAR_two_pass_test

This is just a test of the pipeline on a small RNA dataset.


```
STAR_twopass_three_step_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  /francislab/data1/raw/20211001-EV/fastq/*_R1.fastq.gz

```

