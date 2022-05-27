


Link previous run of read_count and base_count

/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210819-kmers_from_EV_comparison/out/
WY-A85D_R2.25.base_count.txt
WY-A85D_R2.25.read_count.txt

```
for f in /francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20210819-kmers_from_EV_comparison/out/*_count.txt ; do
ln -s ${f} out/
done


```

```
cp /francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25.GBMmut/output_fi.tsv GBMmut_output_fi.tsv
cp /francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25.GBMWT/output_fi.tsv  GBMWT_output_fi.tsv
cp /francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25.Oligo/output_fi.tsv  Oligo_output_fi.tsv
cp /francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25.Astro/output_fi.tsv  Astro_output_fi.tsv
```

```
/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20200803-bamtofastq/subject/??-????_R?.fastq.gz


tail -q -n +2 /francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25.{GBMmut,GBMWT,Oligo,Astro}/output_fi.tsv | awk '{print $1}' | sort > kmers.fw.txt
tail -q -n +2 /francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25.{GBMmut,GBMWT,Oligo,Astro}/output_fi.tsv | awk '{print $1}' | sort | rev | tr "ACTG" "TGAC" > kmers.rc.txt

sort kmers.??.txt > kmers.all.txt


./count_kmers.bash

./aggregate.bash
```


```
cat kmers.fw.txt | awk '{print ">"$1; print $1}' > kmers.fw.fasta
bowtie2 --threads 8 --very-sensitive -f -U kmers.fw.fasta -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts > kmers.fw.sam
```



```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20210901-kmers_from_EV_comparison"
curl -netrc -X MKCOL "${BOX}/"
curl -netrc -T kmers.fw.txt "${BOX}/"
curl -netrc -T kmers.rc.txt "${BOX}/"
curl -netrc -T TCGA.Glioma.metadata.tsv "${BOX}/"
curl -netrc -T GBMmut_output_fi.tsv "${BOX}/"
curl -netrc -T GBMWT_output_fi.tsv "${BOX}/"
curl -netrc -T Oligo_output_fi.tsv "${BOX}/"
curl -netrc -T Astro_output_fi.tsv "${BOX}/"
curl -netrc -T subject_raw_counts.csv.gz "${BOX}/"
curl -netrc -T subject_normal_counts.csv.gz "${BOX}/"
```

