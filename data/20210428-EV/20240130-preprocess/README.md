
#	20210428-EV/20240130-preprocess


44 samples


```
mkdir -p in

for f in /francislab/data1/raw/20210428-EV/Hansen/SFHH005*_R1_001.fastq.gz ; do
echo $f
l=$( basename ${f} _R1_001.fastq.gz )
echo $l
l=${l%_S*}
echo ${l}
ln -s ${f} in/${l}.fastq.gz
done
```



```
EV_preprocessing_array_wrapper.bash --threads 8 --out ${PWD}/out --extension .fastq.gz ${PWD}/in/SFHH005*fastq.gz
```







---


```
./report.bash > report.md
sed -e 's/ | /,/g' -e 's/ \?| \?//g' -e '2d' report.md > report.csv
box_upload.bash report.csv
```


blanks

```
SFHH005v	blank
SFHH005ar	blank
1_11	blank
4_10	blank
7_7	blank
8_4	blank
```

```
409809 out/SFHH005aq.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt
581349 out/SFHH005an.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt
600624 out/SFHH005s.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt
645709 out/SFHH005o.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt
718095 out/SFHH005z.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt
766138 out/SFHH005al.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt

1635508 out/SFHH005v.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt ---- BLANK

2454071 out/SFHH005c.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt
2760143 out/SFHH005e.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt
4934776 out/SFHH005ar.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt ---- BLANK?
8978698 out/SFHH005h.umi.trim.Aligned.sortedByCoord.out.umi_tag.fixmate.deduped.S0.fastq.gz.read_count.txt
```


