
#	20250409-Illumina-PhIP/20250409b-bowtie2



```

bowtie2_array_wrapper.bash --single --threads 8 --sort --very-sensitive \
  --norc --extension .fastq.gz --outdir ${PWD}/out \
  -x /francislab/data1/refs/PhIP-Seq/VIR3_clean.1-84 \
  ${PWD}/../20250409a-cutadapt/out/*fastq.gz

```



```

for f in *bam ; do
echo $f
samtools view -q40 -F4 ${f} | awk '{print $3}' | gzip > ${f}.aligned_sequences.q40.txt.gz
chmod a-w ${f}.aligned_sequences.q40.txt.gz
zcat ${f}.aligned_sequences.txt.gz | sort --parallel=8 | uniq -c | sort -rn > ${f}.aligned_sequence_counts.q40.txt
chmod a-w ${f}.aligned_sequence_counts.q40.txt

samtools view -q20 -F4 ${f} | awk '{print $3}' | gzip > ${f}.aligned_sequences.q20.txt.gz
chmod a-w ${f}.aligned_sequences.q20.txt.gz
zcat ${f}.aligned_sequences.txt.gz | sort --parallel=8 | uniq -c | sort -rn > ${f}.aligned_sequence_counts.q20.txt
chmod a-w ${f}.aligned_sequence_counts.q20.txt
done
```



```

./report.bash > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report*csv

./tile_counts.Rmd
box_upload.bash tile_counts.html 

```



