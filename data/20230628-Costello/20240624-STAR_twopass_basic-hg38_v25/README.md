
#	20230628-Costello/20240624-STAR_twopass_basic-hg38_v25

Rerunning using STAR's Basic twopassMode rather than manually with entire dataset's splice junctions.

568 samples


```

STAR_twopass_basic_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_25/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20231004-cutadapt/out/*_R1.fastq.gz

```


