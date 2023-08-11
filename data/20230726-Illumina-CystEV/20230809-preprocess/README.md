
#	20230726-Illumina-CystEV/20230809-preprocess


So wrong adapters in 20230801-cutadapt
And we have a UMI which I didn't deal with



Continue Format filter? Yes. 18+GTT - keep a count
Where is the UMI? Beginning of R2?
Use UMI and deduplicate or just trim and ignore? dedup
Deup and preserve unaligned? Ignore unaligned for now.
Viral discover on cyst fluid samples only?
Create model for old and new cyst fluid only and test on serum.
Trim precede TTTTTTT on R2?
Create report



```

EV_preprocessing_array_wrapper.bash --out ${PWD}/out --extension _R1.fastq.gz \
  /francislab/data1/raw/20230726-Illumina-CystEV/fastq/*R1.fastq.gz


```




```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv

```








Test


out_base=test/1_10
bamtofastq gz=1 collate=1 inputformat=bam filename=out/1_10.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam \
exclude="DUP,SECONDARY,SUPPLEMENTARY" \
F=${out_base}.R1.fastq.gz \
F2=${out_base}.R2.fastq.gz \
S=${out_base}.S0.fastq.gz \
O=${out_base}.O1.fastq.gz \
O2=${out_base}.O2.fastq.gz


samtools view -f1024 out/1_10.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam | awk '{[V] 2	5.21529MB/s	23148.4
print $1}' | head
VH00749:75:AACVVCTM5:1:1604:20049:33525
VH00749:75:AACVVCTM5:1:1604:20049:33525
VH00749:75:AACVVCTM5:1:1406:34061:19818
VH00749:75:AACVVCTM5:1:2109:51028:4181
VH00749:75:AACVVCTM5:1:1306:66157:48235
VH00749:75:AACVVCTM5:1:2106:64794:4881
VH00749:75:AACVVCTM5:1:1409:60117:18758
VH00749:75:AACVVCTM5:1:2510:49285:28224
VH00749:75:AACVVCTM5:1:2604:17853:32465
VH00749:75:AACVVCTM5:1:1104:53868:11034


zgrep VH00749:75:AACVVCTM5:1:1604:20049:33525 test/*gz


zcat test/*gz | wc -l
19155112


samtools view -c out/1_10.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam


mkdir test2
out_base=test2/1_10
bamtofastq gz=1 collate=1 inputformat=bam filename=out/1_10.format.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.bam \
exclude=SECONDARY,SUPPLEMENTARY \
F=${out_base}.R1.fastq.gz \
F2=${out_base}.R2.fastq.gz \
S=${out_base}.S0.fastq.gz \
O=${out_base}.O1.fastq.gz \
O2=${out_base}.O2.fastq.gz



