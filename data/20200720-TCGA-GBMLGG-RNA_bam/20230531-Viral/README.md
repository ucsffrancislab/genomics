
#	20230531-Viral

```

bowtie2_array_wrapper.bash --no-unal --sort --extension _R1.fastq.gz --very-sensitive -x /francislab/data1/working/20211111-hg38-viral-homology/RMHM --outdir ${PWD}/e2e --threads 8 /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/*_R1.fastq.gz

bowtie2_array_wrapper.bash --no-unal --sort --extension _R1.fastq.gz --very-sensitive-local -x /francislab/data1/working/20211111-hg38-viral-homology/RMHM --outdir ${PWD}/local --threads 8 /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/*_R1.fastq.gz

bowtie2_array_wrapper.bash --no-unal --sort --extension _R1.fastq.gz --very-sensitive -x /francislab/data1/refs/refseq/viral-20220923/NC_001669.1/NC_001669.1_Simian_virus_40_complete_genome --outdir ${PWD}/e2e_SV40 --threads 8 /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/out/*_R1.fastq.gz

```


```

grep "^>" /francislab/data1/working/20211111-hg38-viral-homology/RMHM.fasta | tr -d "^>" | sed 's/ /        /' | gzip >  accession_description.tsv.gz

chmod -w accession_description.tsv.gz 

```


```

./merge.py --int --output e2e_counts.tsv.gz   e2e/*.RMHM.bam.aligned_sequence_counts.txt && chmod -w e2e_counts.tsv.gz

./merge.py --int --output local_counts.tsv.gz local/*.RMHM.bam.aligned_sequence_counts.txt && chmod -w local_counts.tsv.gz

```



```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in e2e_counts.tsv local_counts.tsv /francislab/data1/working/20211111-hg38-viral-homology/RMHM.fasta.gz accession_description.tsv.gz ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```





##	20230731


```

echo "accession,description" > accession_description.csv
cat /francislab/data1/refs/refseq/viral-20210916/viral_sequences.txt | sed "s/[',]//g" | xargs -I% basename % .fa | sed 's/_/,/2' | sort >> accession_description.csv


```



```
for bam in e2e/*bam ; do
echo $bam
samtools view -q20 -f 2 ${bam} | cut -f3 | sort | uniq -c | sort -k1nr > ${bam}.q20.proper_pair_aligned_sequence_counts.txt
samtools view -q30 -f 2 ${bam} | cut -f3 | sort | uniq -c | sort -k1nr > ${bam}.q30.proper_pair_aligned_sequence_counts.txt
samtools view -q40 -f 2 ${bam} | cut -f3 | sort | uniq -c | sort -k1nr > ${bam}.q40.proper_pair_aligned_sequence_counts.txt
done



for q in q20 q30 q40 ; do
python3 ~/.local/bin/merge_uniq-c.py --int --out merged_e2e_proper_pair_${q}.csv e2e/*.RMHM.bam.${q}.proper_pair_aligned_sequence_counts.txt
join --header -t, accession_description.csv merged_e2e_proper_pair_${q}.csv > merged_e2e_proper_pair_${q}_with_description.csv
done



BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in merged_e2e_proper_pair_q??_with_description*.csv ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

```








