
#	20201006-GTEx/20230820-RMHMViral


raw read count (paired end)
human unmapped count (single fasta)

```
20201006-GTEx/20230714-STAR - RUNNING ... After ... 
20201006-GTEx/20230*-RMHM
  GTEx viral read count
  tpm over total aligned to virus
  end-to-end, bowtie2 q30, length filter of 50bp RMHM viral

  include body site for sample
   sample, site, v1 count, v2 count, v3 count, ... 
  sample1, site,        #,        #,        #, ... 
  sample2, site,        #,        #,        #, ... 
  sample3, site,        #,        #,        #, ... 
  sample4, site,        #,        #,        #, ... 
```
  



end-to-end, bowtie2 q30, length filter of 50bp RMHM viral



```

bowtie2_array_wrapper.bash -f --no-unal --sort --extension .Aligned.sortedByCoord.out.unmapped.fasta.gz --very-sensitive --threads 8 \
--single -x /francislab/data1/working/20211111-hg38-viral-homology/RMHM \
--outdir ${PWD}/out ${PWD}/../20230818-STAR-GRCh38/out/*.Aligned.sortedByCoord.out.unmapped.fasta.gz

```


```
echo "accession,description" > accession_description.csv
cat /francislab/data1/refs/refseq/viral-20210916/viral_sequences.txt | sed "s/[',]//g" | xargs -I% basename % .fa | sed 's/_/,/2' | sort >> accession_description.csv

```




```
cat /francislab/data1/raw/20201006-GTEx/SraRunTable.txt | awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS=","}(NR==1 || $21=="Brain"){print $1,$11}' | sort > body_site.csv

```


```
module load samtools
for bam in out/*RMHM.bam ; do
echo $bam
for q in 20 25 30 35 40 ; do
for l in 20 30 40 50 ; do
o=${bam}.q${q}.l${l}.aligned_sequence_counts.txt
if [ ! -f ${o} ] ; then
samtools view -q ${q} ${bam} | awk -v l=${l} '(length($10)>l){print $3}' | sort | uniq -c | sort -k1nr > ${o}
fi
done ; done ; done

./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '/^---/d' report.md > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report.csv report.t.csv

```

##	20230928



```
module load samtools
for bam in out/*RMHM.bam ; do
echo $bam
for q in 40 ; do
for l in 60 70 80 90 ; do
o=${bam}.q${q}.l${l}.aligned_sequence_counts.txt
if [ ! -f ${o} ] ; then
samtools view -q ${q} ${bam} | awk -v l=${l} '(length($10)>l){print $3}' | sort | uniq -c | sort -k1nr > ${o}
fi
done ; done ; done

./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '/^---/d' report.md > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report.csv report.t.csv

```



##	20231002


```
cat /francislab/data1/raw/20201006-GTEx/SraRunTable.csv | awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS=","}(NR==1 || $21=="Brain"){print $1,$8}' | sort > BioSample.csv

./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '/^---/d' report.md > report.csv
cat report.csv | datamash transpose -t, > tmp
head -1 tmp > report.t.csv
tail -n +2 tmp | sort -t, -k2,2 >> report.t.csv

box_upload.bash report.csv report.t.csv


```



