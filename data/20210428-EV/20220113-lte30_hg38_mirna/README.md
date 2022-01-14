



20210909-Retro was made from all reads, pretrimmed and then trimmed again. No length selection.

Here we are only interested in the short reads.



Pretrimmed, trimmed, selected short reads...
```
/francislab/data1/working/20210428-EV/20210511-trimming/

/francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH00*.cutadapt2.lte30.fastq.gz

```

```
mkdir out
for f in /francislab/data1/working/20210428-EV/20210518-preprocessing/output/SFHH00*.cutadapt2.lte30.fastq.gz ; do
echo $f
b=$(basename $f .fastq.gz)
~/.local/bin/bowtie2.bash --sort --threads 8 --very-sensitive-local \
-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts \
-U ${f} --output out/${b}.bam
done

```




align hg38

featureCount



```
chr1    .       miRNA_primary_transcript        17369   17436   .       -       .       ID=MI0022705;Alias=MI0022705;Name=hsa-mir-6859-1
chr1    .       miRNA   17409   17431   .       -       .       ID=MIMAT0027618;Alias=MIMAT0027618;Name=hsa-miR-6859-5p;Derives_from=MI0022705
chr1    .       miRNA   17369   17391   .       -       .       ID=MIMAT0027619;Alias=MIMAT0027619;Name=hsa-miR-6859-3p;Derives_from=MI0022705
chr1    .       miRNA_primary_transcript        30366   30503   .       +       .       ID=MI0006363;Alias=MI0006363;Name=hsa-mir-1302-2
```

```
ln -s /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 mirna.gff
```

Compile feature count matrices

```
for j in 5 6 ; do
for g in mirna ; do
for t in cutadapt ; do
for i in 2 ; do
featureCounts -a ${g}.gff -t miRNA_primary_transcript -g Name -o feature_counts.${j}.${t}${i}.${g}.tsv out/SFHH00${j}*.${t}${i}.lte30.bam
sed -i -e "1,2s'out/''g" -e "1,2s'.${t}${i}.lte30.bam''g" feature_counts.${j}.${t}${i}.${g}.tsv 
sed -i -e "1,2s'out/''g" -e "1,2s'.${t}${i}.lte30.bam''g" feature_counts.${j}.${t}${i}.${g}.tsv.summary 
done ; done ; done ; done
```






```
rename tsv.summary summary.tsv *tsv.summary
```



```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210428-EV/20220113-lte30_hg38_mirna"
curl -netrc -X MKCOL "${BOX}/"

for f in *tsv ;do echo $f; curl -netrc -T $f "${BOX}/" ; done
```







