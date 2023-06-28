
#	20201006-GTEx/20230622-RMHMViral




From "A tissue level atlas of the healthy human virome"

https://bmcbiol.biomedcentral.com/articles/10.1186/s12915-020-00785-5

Additional file 2: Table S2. List of the 39 viral species detected in this study.

https://static-content.springer.com/esm/art%3A10.1186%2Fs12915-020-00785-5/MediaObjects/12915_2020_785_MOESM2_ESM.xlsx

Additional file 3: Table S3. Read count (from each of 8990 samples used) of the respective 39 viral species detected in this study.

https://static-content.springer.com/esm/art%3A10.1186%2Fs12915-020-00785-5/MediaObjects/12915_2020_785_MOESM3_ESM.xlsx




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



