
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

