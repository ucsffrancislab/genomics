

#	20230519-Viral





```

bowtie2_array_wrapper.bash --no-unal --sort --extension _trimmed.1.fastq.gz --very-sensitive -x /francislab/data1/working/20211111-hg38-viral-homology/RMHM --outdir /francislab/data1/working/20220804-RaleighLab-RNASeq/20230519-Viral/e2e --threads 8 /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM*_trimmed.1.fastq.gz 

bowtie2_array_wrapper.bash --no-unal --sort --extension _trimmed.1.fastq.gz --very-sensitive-local -x /francislab/data1/working/20211111-hg38-viral-homology/RMHM --outdir /francislab/data1/working/20220804-RaleighLab-RNASeq/20230519-Viral/local --threads 8 /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM*_trimmed.1.fastq.gz 




bowtie2_array_wrapper.bash --no-unal --sort --extension _trimmed.1.fastq.gz --very-sensitive -x /francislab/data1/refs/refseq/viral-20220923/NC_001669.1/NC_001669.1_Simian_virus_40_complete_genome --outdir /francislab/data1/working/20220804-RaleighLab-RNASeq/20230519-Viral/e2e_SV40 --threads 8 /raleighlab/data1/naomi/HKU_RNA_seq/Data_Analysis/FASTQ/Trimmed_Data/Arriba/QM*_trimmed.1.fastq.gz 

```


```

grep "^>" /francislab/data1/working/20211111-hg38-viral-homology/RMHM.fasta | tr -d "^>" | sed 's/ /        /' | gzip >  accession_description.tsv.gz

chmod -w accession_description.tsv.gz 

```



```

./merge.py --int --output e2e_counts.tsv.gz   e2e/QM*.RMHM.bam.aligned_sequence_counts.txt && chmod -w e2e_counts.tsv.gz

./merge.py --int --output local_counts.tsv.gz local/QM*.RMHM.bam.aligned_sequence_counts.txt && chmod -w local_counts.tsv.gz

```





```

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in e2e_counts.tsv local_counts.tsv /francislab/data1/raw/20220804-RaleighLab-RNASeq/ids_DNA_methylation_group.csv /francislab/data1/working/20211111-hg38-viral-homology/RMHM.fasta accession_description.tsv.gz ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done


BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) ) 
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
for f in QM299.RMHM.bam QM17.RMHM.bam QM308.RMHM.bam ; do
echo $f
curl  --silent --ftp-create-dirs -netrc -T local/${f} "${BOX}/local/"
curl  --silent --ftp-create-dirs -netrc -T local/${f}.bai "${BOX}/local/"
curl  --silent --ftp-create-dirs -netrc -T e2e/${f} "${BOX}/e2e/"
curl  --silent --ftp-create-dirs -netrc -T e2e/${f}.bai "${BOX}/e2e/"
done

```






