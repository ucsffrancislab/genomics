
#	20230726-Illumina-CystEV/20230816-RMHMViral


raw read count (paired end)
human unmapped count (single fasta)
viral aligned count?


```

bowtie2_array_wrapper.bash -f --no-unal --sort --extension .format.umi.trim.Aligned.sortedByCoord.out.unmapped.fasta.gz --very-sensitive --threads 8 \
--single -x /francislab/data1/working/20211111-hg38-viral-homology/RMHM \
--outdir ${PWD}/out ${PWD}/../20230809-preprocess/out/*.format.umi.trim.Aligned.sortedByCoord.out.unmapped.fasta.gz

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
awk 'BEGIN{FS=OFS=","}((NR==1)||($7=="Kirkwood Cyst Study")&&($8=="cyst fluid")&&($NF!="")){print $1,$NF}' /francislab/data1/raw/20230726-Illumina-CystEV/cyst_fluid_et_al_ev_manifest_library_index_and_covarate_file_with_analysis_groups_8-1-23hmhmz.csv > metadata.csv
```



```


for q in 20 25 30 ; do
for l in 20 30 40 50 ; do
python3 ~/.local/bin/merge_uniq-c.py --int -o merged.q${q}.l${l}.csv out/*.q${q}.l${l}.aligned_sequence_counts.txt
join -t, --header accession_description.csv merged.q${q}.l${l}.csv | datamash transpose -t, > tmp1.csv
( ( head -2 tmp1.csv ) && ( tail -n +3 tmp1.csv | sort -t, -k1,1 ) ) > tmp2.csv
head -2 tmp2.csv > tmp3.csv
tail -n +3 tmp2.csv > tmp4.csv
( ( head -1 tmp3.csv ) && ( cat tmp4.csv ) ) > tmp5.csv
join -t, --header metadata.csv tmp5.csv > tmp6.csv
( ( head -1 tmp6.csv ) && ( echo -n "," && tail -n 1 tmp3.csv ) && ( tail -n +2 tmp6.csv ) ) > tmp7.csv
( ( head -2 tmp7.csv ) && ( tail -n +3 tmp7.csv | sort -t, -k2,2 -k1,1 ) ) | datamash transpose -t, > merged.q${q}.l${l}.joins.csv
done ; done
\rm -f tmp?.csv
```



```
box_upload.bash merged*joins.csv

```


```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
cat report.csv | datamash transpose -t, > report.t.csv
box_upload.bash report.csv report.t.csv


```
