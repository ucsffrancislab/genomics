
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



##	20231003


```

cat /francislab/data1/raw/20201006-GTEx/SraRunTable.csv | awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS=","}(NR==1 || $21=="Brain"){print $1,$10}' | sort > biospecimen_repository_sample_id.csv

./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '/^---/d' report.md > report.csv
cat report.csv | datamash transpose -t, > tmp
head -1 tmp > report.t.csv
tail -n +2 tmp | sort -t, -k2,2 >> report.t.csv

box_upload.bash report.csv report.t.csv

```


##	20231004

Extract and combine all EBV aligned reads ...


```
module load samtools
cp /francislab/data1/working/20211111-hg38-viral-homology/RMHM/NC_007605.1.fasta ./
samtools faidx NC_007605.1.fasta

\rm tmp1
for b in out/*bam ; do echo $b; samtools view $b NC_007605.1 >> tmp1 ; done

samtools view -o tmp2 -ht NC_007605.1.fasta.fai tmp1
samtools sort -o all_gtex_NC_007605.1.bam tmp2
samtools index all_gtex_NC_007605.1.bam
\rm tmp1 tmp2

box_upload.bash all_gtex_NC_007605.1.bam all_gtex_NC_007605.1.bam.bai NC_007605.1.fasta NC_007605.1.fasta.fai
```



```
python3 ~/.local/bin/merge_uniq-c.py --int -o merged.csv out/*.q30.l60.aligned_sequence_counts.txt


awk '{c[$2]+=$1}END{for(i in c){if(c[i]>1000) print i}}' out/*.RMHM.bam.q30.l60.aligned_sequence_counts.txt > top_accessions

for txt in out/*.RMHM.bam.q30.l60.aligned_sequence_counts.txt ; do
echo $txt
grep -f top_accessions ${txt} > ${txt%.txt}.top.txt
done


python3 ~/.local/bin/merge_uniq-c.py --int -o tmp1 out/*.q30.l60.aligned_sequence_counts.top.txt

cat tmp1 | datamash transpose -t, > tmp2
join -t, --header body_site.csv tmp2 > tmp3
join -t, --header BioSample.csv tmp3 > tmp4
join -t, --header biospecimen_repository_sample_id.csv tmp4 > tmp5
cat tmp5 | datamash transpose -t, > tmp6

head -3 tmp6 | sed 's/,/,description,/' > merged.top.csv
join -t, --header accession_description.csv <( tail -n +4 tmp6 ) >> merged.top.csv
cat merged.top.csv | datamash transpose -t, > merged.top.t.csv

box_upload.bash merged.top.csv merged.top.t.csv
\rm tmp?

```



```

echo "accession,count" > tmp
awk '{c[$2]+=$1}END{for(i in c){if(c[i]>1000) print i","c[i]}}' out/*.RMHM.bam.q30.l60.aligned_sequence_counts.txt | sort -t, -k1,1 >> tmp
join -t, --header accession_description.csv tmp > total_counts.csv

```




Extract and combine all HSV1 aligned reads ...


```
module load samtools
cp /francislab/data1/working/20211111-hg38-viral-homology/RMHM/NC_001806.2.fasta ./
samtools faidx NC_001806.2.fasta

\rm tmp1
for b in out/*bam ; do echo $b; samtools view $b NC_001806.2 >> tmp1 ; done

samtools view -o tmp2 -ht NC_001806.2.fasta.fai tmp1
samtools sort -o all_gtex_NC_001806.2.bam tmp2
samtools index all_gtex_NC_001806.2.bam
\rm tmp1 tmp2

box_upload.bash all_gtex_NC_001806.2.bam all_gtex_NC_001806.2.bam.bai NC_001806.2.fasta NC_001806.2.fasta.fai
```




```
echo "accession,subject_count" > tmp1
awk '($1>10){print $2}' out/*.RMHM.bam.q30.l60.aligned_sequence_counts.txt | sort | uniq -c | sort -k1nr,1 | head | awk '{print $2","$1}' | sort -t, -k1,1 >> tmp1
join -t, --header accession_description.csv tmp1 > tmp2
head -1 tmp2 > top10gt10.csv
tail -n +2 tmp2 | sort -t, -k3nr,3 >> top10gt10.csv

echo "accession,subject_count" > tmp1
awk '($1>100){print $2}' out/*.RMHM.bam.q30.l60.aligned_sequence_counts.txt | sort | uniq -c | sort -k1nr,1 | head | awk '{print $2","$1}' | sort -t, -k1,1 >> tmp1
join -t, --header accession_description.csv tmp1 > tmp2
head -1 tmp2 > top10gt100.csv
tail -n +2 tmp2 | sort -t, -k3nr,3 >> top10gt100.csv

echo "accession,subject_count" > tmp1
awk '($1>1000){print $2}' out/*.RMHM.bam.q30.l60.aligned_sequence_counts.txt | sort | uniq -c | sort -k1nr,1 | head | awk '{print $2","$1}' | sort -t, -k1,1 >> tmp1
join -t, --header accession_description.csv tmp1 > tmp2
head -1 tmp2 > top10gt1000.csv
tail -n +2 tmp2 | sort -t, -k3nr,3 >> top10gt1000.csv

box_upload.bash top10gt10*csv

```



