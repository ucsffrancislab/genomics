


Align to hg38

```
./align.bash
```


Compile feature count matrices

```
for j in 5 6 ; do
for g in LTR Retroposon ; do
for t in bbduk cutadapt ; do
for i in 1 2 3 ; do
featureCounts -a /francislab/data1/refs/sources/igv.org.genomes/hg38/rmsk/hg38_rmsk_${g}.gtf -t feature -g feature_name -o feature_counts.${j}.${t}${i}.${g}.tsv output/SFHH00${j}*.${t}${i}.bam
done ; done ; done ; done
```

Remove path and extensions from tsv headers

```
for j in 5 6 ; do
for g in LTR Retroposon ; do
for t in bbduk cutadapt ; do
for i in 1 2 3 ; do
sed -i -e "1,2s'output/''g" -e "1,2s'.${t}${i}.bam''g" feature_counts.${j}.${t}${i}.${g}.tsv 
sed -i -e "1,2s'output/''g" -e "1,2s'.${t}${i}.bam''g" feature_counts.${j}.${t}${i}.${g}.tsv.summary 
done ; done ; done ; done
```


```
rename tsv.summary summary.tsv *summary
```







ln -s /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 mirna.gff

chr1	.	miRNA_primary_transcript	17369	17436	.	-	.	ID=MI0022705;Alias=MI0022705;Name=hsa-mir-6859-1
chr1	.	miRNA	17409	17431	.	-	.	ID=MIMAT0027618;Alias=MIMAT0027618;Name=hsa-miR-6859-5p;Derives_from=MI0022705
chr1	.	miRNA	17369	17391	.	-	.	ID=MIMAT0027619;Alias=MIMAT0027619;Name=hsa-miR-6859-3p;Derives_from=MI0022705
chr1	.	miRNA_primary_transcript	30366	30503	.	+	.	ID=MI0006363;Alias=MI0006363;Name=hsa-mir-1302-2


ln -s /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf genes.gff

chr1	ncbiRefSeq	transcript	11874	14409	.	+	.	gene_id "DDX11L1"; transcript_id "NR_046018.2";  gene_name "DDX11L1";
chr1	ncbiRefSeq	exon	11874	12227	.	+	.	gene_id "DDX11L1"; transcript_id "NR_046018.2"; exon_number "1"; exon_id "NR_046018.2.1"; gene_name "DDX11L1";
chr1	ncbiRefSeq	exon	12613	12721	.	+	.	gene_id "DDX11L1"; transcript_id "NR_046018.2"; exon_number "2"; exon_id "NR_046018.2.2"; gene_name "DDX11L1";





Compile feature count matrices

```
for j in 5 6 ; do
for g in mirna ; do
for t in cutadapt ; do
for i in 2 ; do
featureCounts -a ${g}.gff -t miRNA_primary_transcript -g Name -o feature_counts.${j}.${t}${i}.${g}.tsv output/SFHH00${j}*.${t}${i}.bam
done ; done ; done ; done

for j in 5 6 ; do
for g in genes ; do
for t in cutadapt ; do
for i in 2 ; do
featureCounts -a ${g}.gff -t transcript -g gene_name -o feature_counts.${j}.${t}${i}.${g}.tsv output/SFHH00${j}*.${t}${i}.bam
done ; done ; done ; done
```





Remove path and extensions from tsv headers

```
for j in 5 6 ; do
for g in mirna genes ; do
for t in cutadapt ; do
for i in 2 ; do
sed -i -e "1,2s'output/''g" -e "1,2s'.${t}${i}.bam''g" feature_counts.${j}.${t}${i}.${g}.tsv 
sed -i -e "1,2s'output/''g" -e "1,2s'.${t}${i}.bam''g" feature_counts.${j}.${t}${i}.${g}.tsv.summary 
done ; done ; done ; done
```


```
rename tsv.summary summary.tsv *summary
```



