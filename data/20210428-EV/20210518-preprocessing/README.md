

This preprocessing starts with pre-trimmed data?



```BASH
./preprocess.bash


./postpreprocess.bash

```


---

```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210518-preprocessing"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210518-preprocessing/fastqc"
curl -netrc -X MKCOL "${BOX}/"

for f in output/*fastqc* ;do echo $f; curl -netrc -T $f "${BOX}/" ; done
```


python3 ./merge_uniq-c.py --int -o ${i}.cutadapt2.${s}.csv output/SFHH00${i}*.cutadapt2.lte30.${s}.bam.aligned_sequence_counts.txt

```
for i in 5 6 ; do
for s in bowtie2.mirna.all bowtie2.mirna bowtie.mirna.all bowtie.mirna STAR.mirna.Aligned.sortedByCoord.out ; do
python3 ~/.local/bin/merge_uniq-c.py --int -o ${i}.cutadapt2.${s}.csv output/SFHH00${i}*.cutadapt2.lte30.${s}.bam.aligned_sequence_counts.txt
done ; done
```

```
python3 ./merge_uniq-c.py --int -o control.csv output/SFHH00?{k,ag}.cutadapt2.lte30.*.bam.aligned_sequence_counts.txt
```


```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20210518-preprocessing"
curl -netrc -X MKCOL "${BOX}/"

for f in *csv ;do echo $f; curl -netrc -T $f "${BOX}/" ; done
```







featureCounts -t transcript -a /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf -o SFHH005.cutadapt2.gt30.bowtie2.hg38.ncbiRefSeq.transcript.gene_id.tsv SFHH005*.cutadapt2.gt30.bowtie2.hg38.bam



for f in output/SFHH005*.cutadapt2.gt30.fastq.gz ; do
echo $f
bowtie2.bash --no-unal -x pBABE_EGFRvIII -q -U $f -o ${f%%.fastq.gz}.pBABE_EGFRvIII.bam
done





