
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



Why didn't I use the filtered and trimmed?
```
ll /francislab/data1/working/20201006-GTEx/20201116-preprocess/trimmed/*_R1.fastq.gz | wc -l
1438
```

```
bowtie2_array_wrapper.bash --no-unal --sort --extension _R1.fastq.gz --very-sensitive --threads 8 \
-x /francislab/data1/working/20211111-hg38-viral-homology/RMHM \
--outdir /francislab/data1/working/20201006-GTEx/20230622-RMHMViral/out-preprocessed-e2e \
/francislab/data1/working/20201006-GTEx/20201116-preprocess/trimmed/*_R1.fastq.gz

```





```

python3 ~/.local/bin/merge_uniq-c.py --int --out merged_loc.csv out-loc/*.RMHM.bam.aligned_sequence_counts.txt

echo "accession,description" > accession_description.csv
cat /francislab/data1/refs/refseq/viral-20210916/viral_sequences.txt | sed "s/[',]//g" | xargs -I% basename % .fa | sed 's/_/,/2' | sort >> accession_description.csv


join --header -t, accession_description.csv merged_loc.csv > merged_loc_with_description.csv


awk -F, '(NR==1){print;next}{s=0;for(i=3;i<=NF;i++){s+=$i};if(s>100)print}' merged_loc_with_description.csv accession_description.csv > merged_loc_with_description_total_gt_100.csv 

awk -F, '(NR==1){print;next}{s=0;for(i=3;i<=NF;i++){s+=$i};if(s>200)print}' merged_loc_with_description.csv accession_description.csv > merged_loc_with_description_total_gt_200.csv 

awk -F, '(NR==1){print;next}{s=0;for(i=3;i<=NF;i++){s+=$i};if(s>500)print}' merged_loc_with_description.csv accession_description.csv > merged_loc_with_description_total_gt_500.csv 

```



```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged_loc_with_description*.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```


```
for bam in out-loc/*bam ; do
echo $bam
samtools view -f 2 ${bam} | cut -f3 | sort | uniq -c | sort -k1nr > ${bam}.proper_pair_aligned_sequence_counts.txt
done
```



```
python3 ~/.local/bin/merge_uniq-c.py --int --out merged_loc_proper_pair.csv out-loc/*.RMHM.bam.proper_pair_aligned_sequence_counts.txt

join --header -t, accession_description.csv merged_loc_proper_pair.csv > merged_loc_proper_pair_with_description.csv

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged_loc_proper_pair_with_description*.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```


##	20230716



```
for bam in out-preprocessed-e2e/*bam ; do
echo $bam
samtools view -f 2 ${bam} | cut -f3 | sort | uniq -c | sort -k1nr > ${bam}.proper_pair_aligned_sequence_counts.txt
done


python3 ~/.local/bin/merge_uniq-c.py --int --out merged_preproc_e2e_proper_pair.csv out-preprocessed-e2e/*.RMHM.bam.proper_pair_aligned_sequence_counts.txt

join --header -t, accession_description.csv merged_preproc_e2e_proper_pair.csv > merged_preproc_e2e_proper_pair_with_description.csv

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged_preproc_e2e_proper_pair_with_description*.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```







##	20230717



```
for bam in out-preprocessed-e2e/*bam ; do
echo $bam
samtools view -q10 -f 2 ${bam} | cut -f3 | sort | uniq -c | sort -k1nr > ${bam}.q10.proper_pair_aligned_sequence_counts.txt
samtools view -q20 -f 2 ${bam} | cut -f3 | sort | uniq -c | sort -k1nr > ${bam}.q20.proper_pair_aligned_sequence_counts.txt
samtools view -q30 -f 2 ${bam} | cut -f3 | sort | uniq -c | sort -k1nr > ${bam}.q30.proper_pair_aligned_sequence_counts.txt
samtools view -q40 -f 2 ${bam} | cut -f3 | sort | uniq -c | sort -k1nr > ${bam}.q40.proper_pair_aligned_sequence_counts.txt
done




for q in q10 q20 q30 q40 ; do
python3 ~/.local/bin/merge_uniq-c.py --int --out merged_preproc_e2e_proper_pair_${q}.csv out-preprocessed-e2e/*.RMHM.bam.${q}.proper_pair_aligned_sequence_counts.txt
join --header -t, accession_description.csv merged_preproc_e2e_proper_pair_${q}.csv > merged_preproc_e2e_proper_pair_${q}_with_description.csv
done



BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged_preproc_e2e_proper_pair_q??_with_description*.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```



Normalize by number of reads after trimming * 1 million

```

fastx_count_array_wrapper.bash /francislab/data1/working/20201006-GTEx/20201116-preprocess/trimmed/*_R1.fastq.gz


for txt in out-preprocessed-e2e/*proper_pair_aligned_sequence_counts.txt ; do
echo $txt
f=${txt%.txt}.normalized.txt
if [ -f ${f} ] && [ ! -w ${f} ] ; then
echo "Write-protected ${f} exists. Skipping."
else
echo "Creating ${f}"
srr=$( basename ${txt} .proper_pair_aligned_sequence_counts.txt )
srr=${srr%.RMHM.bam*}
rc=$( cat /francislab/data1/working/20201006-GTEx/20201116-preprocess/trimmed/${srr}_R1.fastq.gz.read_count.txt )
if [ -n "${rc}" ] ; then
echo "Have rc ${rc}"
awk -v rc=${rc} '{print (($1*1000000)/(2*rc)),$2}' ${txt} > ${f}
chmod -w ${f}
fi
fi
done


for q in . .q10. .q20. .q30. .q40. ; do
echo $q
python3 ~/.local/bin/merge_uniq-c.py --out merged_preproc_e2e_proper_pair${q}normalized.csv out-preprocessed-e2e/*.RMHM.bam${q}proper_pair_aligned_sequence_counts.normalized.txt
join --header -t, accession_description.csv merged_preproc_e2e_proper_pair${q}normalized.csv > merged_preproc_e2e_proper_pair${q}normalized_with_description.csv
done



BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged_preproc_e2e_proper_pair*normalized_with_description*.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```




##	20230718



Merge tables with specific body site for grouping


```
head -1 /francislab/data1/raw/20201006-GTEx/SraRunTable.txt | awk -F, '{for(i=1;i<=NF;i++){print i,$i}}'

cat /francislab/data1/raw/20201006-GTEx/SraRunTable.txt | awk 'BEGIN{FPAT="([^,]+)|(\"[^\"]+\")";OFS=","}(NR==1 || $21=="Brain"){print $1,$11}' | sort > body_site.csv

#join --header -t, body_site.csv <( sed 's/,/ /' merged_preproc_e2e_proper_pair${q}normalized_with_description.csv | datamash transpose -t , ) | datamash transpose -t , > merged_preproc_e2e_proper_pair${q}normalized_with_description_bodysite.csv

for q in . .q10. .q20. .q30. .q40. ; do
echo $q
join --header -t, body_site.csv <( sed 's/,/ /' merged_preproc_e2e_proper_pair${q}normalized_with_description.csv | datamash transpose -t , ) > tmp
head -1 tmp > tmp2
tail -n +2 tmp | sort -t, -k2,2 -k1,1 >> tmp2
cat tmp2 | datamash transpose -t , > merged_preproc_e2e_proper_pair${q}normalized_with_description_bodysite.csv
\rm tmp tmp2
done
```


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged_preproc_e2e_proper_pair*normalized_with_description_bodysite.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```




##	20230719

Aggregate merged_preproc_e2e_proper_pair${q}normalized_with_description_bodysite.csv creating matrix of 

```
           site 1     site 2    site 3     
virus 1
virus 2            median values
virus 3

```


```
for f in merged_preproc_e2e_proper_pair*normalized_with_description_bodysite.csv ; do
echo $f
tail -n +2 ${f} | datamash transpose -t, > tmp

out=${f%.csv}_medians.csv

column_count=$( head -1 tmp | awk -F, '{print NF}' )

head -1 tmp > ${out}
( echo -n "All," && cat tmp | datamash median --header-in -t, 2-${column_count} ) >> ${out}

while read body_site ; do
echo $body_site
( echo -n "${body_site#Brain - }," && grep "^${body_site}," tmp | datamash median -t, 2-${column_count} ) >> ${out}
done < <( tail -n +2 tmp | cut -d, -f1 | uniq )
cat ${out} | datamash transpose -t, > ${out%.csv}.t.csv

tail -n +2 ${f} | datamash transpose -t, > tmp

out=${f%.csv}_sums.csv

column_count=$( head -1 tmp | awk -F, '{print NF}' )

head -1 tmp > ${out}
( echo -n "All," && cat tmp | datamash sum --header-in -t, 2-${column_count} ) >> ${out}

while read body_site ; do
echo $body_site
( echo -n "${body_site#Brain - }," && grep "^${body_site}," tmp | datamash sum -t, 2-${column_count} ) >> ${out}
done < <( tail -n +2 tmp | cut -d, -f1 | uniq )
cat ${out} | datamash transpose -t, > ${out%.csv}.t.csv

tail -n +2 ${f} | datamash transpose -t, > tmp

out=${f%.csv}_means.csv

column_count=$( head -1 tmp | awk -F, '{print NF}' )

head -1 tmp > ${out}
( echo -n "All," && cat tmp | datamash mean --header-in -t, 2-${column_count} ) >> ${out}

while read body_site ; do
echo $body_site
( echo -n "${body_site#Brain - }," && grep "^${body_site}," tmp | datamash mean -t, 2-${column_count} ) >> ${out}
done < <( tail -n +2 tmp | cut -d, -f1 | uniq )
cat ${out} | datamash transpose -t, > ${out%.csv}.t.csv
done
```


```
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged_preproc_e2e_proper_pair*normalized_with_description_bodysite_{sum,mean,median}*.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done
```




