
#	20200720-TCGA-GBMLGG-RNA_bam/20231130-STAR-twopass-GRCh38


Gonna have another go at TEProF2 by aligning with STAR two pass



```
STAR_twopass_three_step_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```



