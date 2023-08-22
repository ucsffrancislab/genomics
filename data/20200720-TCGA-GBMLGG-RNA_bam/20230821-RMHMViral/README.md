
#	20200720-TCGA-GBMLGG-RNA_bam/20230821-RMHMViral




```

bowtie2_array_wrapper.bash -f --no-unal --sort --extension .Aligned.sortedByCoord.out.unmapped.fasta.gz --very-sensitive --threads 8 \
--single -x /francislab/data1/working/20211111-hg38-viral-homology/RMHM \
--outdir ${PWD}/out ${PWD}/../20230807-STAR-GRCh38/out/*.Aligned.sortedByCoord.out.unmapped.fasta.gz

```


```
echo "accession,description" > accession_description.csv
cat /francislab/data1/refs/refseq/viral-20210916/viral_sequences.txt | sed "s/[',]//g" | xargs -I% basename % .fa | sed 's/_/,/2' | sort >> accession_description.csv

```



```
module load samtools
for bam in out/*RMHM.bam ; do
echo $bam
for q in 20 25 30 ; do
for l in 20 30 40 50 ; do
samtools view -q ${q} ${bam} | awk -v l=${l} '(length($10)>l){print $3}' | sort | uniq -c | sort -k1nr > ${bam}.q${q}.l${l}.aligned_sequence_counts.txt
done ; done ; done
```





```

./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report.csv report.t.csv

```

