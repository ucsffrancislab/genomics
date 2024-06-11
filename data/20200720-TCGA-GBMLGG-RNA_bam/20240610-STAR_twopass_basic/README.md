
#	20200720-TCGA-GBMLGG-RNA_bam/20240610-STAR_twopass_basic

Redo with twopass basic not manually or by dataset

Rerunning using STAR's Basic twopassMode rather than manually with entire dataset's splice junctions.

Gonna have another go at TEProF2 by aligning with STAR two pass

```

STAR_twopass_basic_array_wrapper.bash --threads 8 \
  --ref /francislab/data1/refs/sources/gencodegenes.org/release_43/GRCh38.primary_assembly.genome \
  --out ${PWD}/out \
  ${PWD}/../20230807-cutadapt/out/*_R1.fastq.gz

```



