
#	20201006-GTEx/20230622-RMHMViral






```

bowtie2_array_wrapper.bash --no-unal --sort --extension _R1.fastq.gz --very-sensitive-local --threads 8 \
-x /francislab/data1/working/20211111-hg38-viral-homology/RMHM \
--outdir /francislab/data1/working/20201006-GTEx/20230622-RMHMViral/out-loc \
/francislab/data1/raw/20201006-GTEx/fastq/*_R1.fastq.gz

bowtie2_array_wrapper.bash --no-unal --sort --extension _R1.fastq.gz --very-sensitive --threads 8 \
-x /francislab/data1/working/20211111-hg38-viral-homology/RMHM \
--outdir /francislab/data1/working/20201006-GTEx/20230622-RMHMViral/out-e2e \
/francislab/data1/raw/20201006-GTEx/fastq/*_R1.fastq.gz

```



