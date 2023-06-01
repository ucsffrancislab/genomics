
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

