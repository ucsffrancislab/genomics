
#	20240328-Illumina-PhIP


```
mkdir download
cd download
wget https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs
chmod +x bs
```

I've already auth'd so ...

```
bs list projects

+-----------------------------------------+-----------+-----------+
|                  Name                   |    Id     | TotalSize |
+-----------------------------------------+-----------+-----------+
| MS_2x151nano_Project71_1-77_Gilly091219 | 141020880 | 546895506 |
| 030524_HH_4PhIP_L1                      | 412054646 | 282865337 |
| 032524_HH_4PhIP_P2                      | 413488296 | 364293052 |
+-----------------------------------------+-----------+-----------+
```


```
bs download project -i 413488296
```

```
cd ..
ll download/*/*z

-rw-r----- 1 gwendt francislab   3781204 Mar 28 10:56 download/L5_022224_L001_ds.509c8a969a3b4e269f295e19be359e63/L5-022224_S1_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab   3109620 Mar 28 10:56 download/L6_022224_L001_ds.c2c9d03bc22e4da8b9cec0e0a9a47375/L6-022224_S2_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 175222239 Mar 28 10:57 download/L7_022224_L001_ds.bac668f3dccd41b9a268d60fb31b3405/L7-022224_S3_L001_R1_001.fastq.gz
-rw-r----- 1 gwendt francislab 182179989 Mar 28 10:57 download/L8_022224_L001_ds.3485709ff07546609626cb4e4c81a73e/L8-022224_S4_L001_R1_001.fastq.gz

```



Note that there is no "Undetermine"?


```
mkdir fastq
cd fastq

for f in ../download/*/*fastq.gz ; do
echo $f
b=$( basename $f _L001_R1_001.fastq.gz ) 
echo $b
b=${b##*_}
echo $b
ln -s ${f} ${b}.fastq.gz
done
```




##	20240402

Downloading reprocessed files



```
mkdir download2
cd download2
wget https://launch.basespace.illumina.com/CLI/latest/amd64-linux/bs
chmod +x bs
```


```
bs download project -i 414057833
cd ..
```


```
mkdir fastq2
cd fastq2

for f in ../download2/*/*fastq.gz ; do
echo $f
b=$( basename $f _L001_R1_001.fastq.gz ) 
echo $b
b=${b##*_}
echo $b
ln -s ${f} ${b}.fastq.gz
done
```



```
for f in S?.fastq.gz ; do
echo $f
zcat $f | sed -n '1~4p' | cut -d: -f10 | sort | uniq -c | sort -k1nr,1 > ${f}.indexes.txt
done
```


Levenshtein is a bit different of a gauge here.

```
echo ",AACCAAG,AACCGCA,AACCTGC,AACGACC"
for i in AACCAAG AACCGCA AACCTGC AACGACC ; do
echo -n $i
for j in AACCAAG AACCGCA AACCTGC AACGACC ; do
c=$( ~/github/ucsffrancislab/genomics/source/levenshtein $i $j | cut -f3 )
echo -n ",${c}"
done 
echo 
done
```






##	20240419


How much of index is messed up? Different than expected?

Ratio of correct indexes to incorrect indexes?

Undetermined alignment and look at indexes of those that aligned



Count all of the reads.
```
zcat S?.fastq.gz | sed -n '1~4p' | wc -l
7069286
```


Count reads.
```
for f in S?.fastq.gz ; do
echo $f
zcat $f | sed -n '1~4p' | wc -l > ${f}.read_count.txt
done
```


Strip out indexes and count them.
```
for f in S?.fastq.gz ; do
echo $f
zcat $f | sed -n '1~4p' | cut -d: -f10 | sort | uniq -c | sort -k1nr,1 > ${f}.indexes.txt
done
```


Confirm total count.
```
zcat S?.fastq.gz | sed -n '1~4p' | wc -l
7069286
```


Select the top index and it should be the expected index.
```
for f in S[1234].fastq.gz.indexes.txt ; do
echo $f
head -1 $f
done
```

```
S1.fastq.gz.indexes.txt
  28701 AACCAAG
S2.fastq.gz.indexes.txt
  22265 AACCGCA
S3.fastq.gz.indexes.txt
2557682 AACCTGC
S4.fastq.gz.indexes.txt
2693597 AACGACC
```


Are any repeated in different files? No.
```
cat *indexes.txt | sed 's/^[[:space:]]*//' | cut -d" " -f2 | sort | uniq -d
```


What percentage of the total are they?
```
for f in S[1234].fastq.gz.indexes.txt ; do
echo $f
c=$( head -1 $f | sed 's/^[[:space:]]*//' | cut -d" " -f1 )
echo "scale=2; 100 * ${c} / 7069286 " | bc -l 2> /dev/null
done
```

```
S1.fastq.gz.indexes.txt
.40
S2.fastq.gz.indexes.txt
.31
S3.fastq.gz.indexes.txt
36.18
S4.fastq.gz.indexes.txt
38.10
```


What percentage of the total are they?
What percentage of the index plus 1 edit are they?
```
for f in S[1234].fastq.gz.read_count.txt ; do
echo $f
c=$( cat $f )
echo "scale=2; 100 * ${c} / 7069286 " | bc -l 2> /dev/null
done
```

```
S1.fastq.gz.read_count.txt
.87
S2.fastq.gz.read_count.txt
.73
S3.fastq.gz.read_count.txt
45.94
S4.fastq.gz.read_count.txt
47.89
```


The number of indexes in each sample.
```
wc -l *indexes.txt
 16948 S0.fastq.gz.indexes.txt
    23 S1.fastq.gz.indexes.txt
    23 S2.fastq.gz.indexes.txt
    23 S3.fastq.gz.indexes.txt
    23 S4.fastq.gz.indexes.txt
```


How many aligned to VIR3_clean with bowtie2 end-to-end?
```
for f in /francislab/data1/working/20240328-Illumina-PhIP/20240328-PhIP-Seq/out/S*.VIR3_clean.bam.aligned_count.txt ; do
b=$( basename $f _bt2alle2e.VIR3_clean.bam.aligned_count.txt )
echo $b
a=$( cat $f )
c=$( cat $b.fastq.gz.read_count.txt )
echo "scale=2; 100 * ${a} / ${c}" | bc -l 2> /dev/null
done
```

```
S0
14.78
S1
38.72
S2
31.90
S3
96.26
S4
97.00
```



What are the indexes of those S0 reads that aligned?

First, ensure that the index stays in the read name.
```
for f in S?.fastq.gz; do
b=$( basename $f .fastq.gz )
zcat ${f} | sed '1~4s/ /:/g' | gzip > ${b}.merged.fastq.gz
done
```

Then reprocess in working dir 



How many different indexes in S0 aligned?
```
samtools view -F4 /francislab/data1/working/20240328-Illumina-PhIP/20240328-PhIP-Seq/out2/S0_bt2alle2e.VIR3_clean.bam | cut -f1 | cut -d: -f11 | sort | uniq | wc -l 
```

```
1827
```


How many different indexes in S0 aligned > 10 times?
```
samtools view -F4 /francislab/data1/working/20240328-Illumina-PhIP/20240328-PhIP-Seq/out2/S0_bt2alle2e.VIR3_clean.bam | cut -f1 | cut -d: -f11 | sort | uniq -c | awk '($1>10)' | wc -l 
```

```
288
```



What are the top 20 aligned indexes?
And how do they compare to expected indexes?
```
samtools view -F4 /francislab/data1/working/20240328-Illumina-PhIP/20240328-PhIP-Seq/out2/S0_bt2alle2e.VIR3_clean.bam | cut -f1 | cut -d: -f11 | sort | uniq -c | sort -k1nr,1 | head -n 20
  15945 AACGAAN - 2 edits from AACCAAG and AACGACC
   5743 AACTAGA - 3 edits from all
   4814 AACTCCG - 3 edits from 3
   3546 AACGGCN - 2 edits from AACGACC and AACCGCA
   2354 AACTAGN - 3 edits from 3
   2259 CACCTGN - 2 from AACCTGC
   2240 CACGACN - 2 from AACGACC
   2014 AACCGGN - 2 from AACCGCA
   1956 AACTCCN
   1788 AACCCTG
   1530 AACCTAN
   1435 AACCACN
   1353 AACCTTG
   1252 AACCGAC
   1161 AACACCA
   1118 CAACGAC
    894 AACCGGG
    808 CAACCTG
    704 AACATGN
    571 AACCTCN
```


Primary alignments only
```
samtools view -F2308 /francislab/data1/working/20240328-Illumina-PhIP/20240328-PhIP-Seq/out2/S0_bt2alle2e.VIR3_clean.bam | cut -f1 | cut -d: -f11 | sort | uniq -c | awk '($1>10)' | sort -k1nr,1 | head -n 20
  10019 AACGAAN
   3640 AACTAGA
   3050 AACTCCG
   2226 AACGGCN
   1471 AACTAGN
   1425 CACCTGN
   1401 CACGACN
   1270 AACCGGN
   1234 AACTCCN
   1101 AACCCTG
    972 AACCTAN
    905 AACCACN
    835 AACCTTG
    778 AACCGAC
    734 AACACCA
    717 CAACGAC
    557 AACCGGG
    502 CAACCTG
    449 AACATGN
    376 AACCTCN
```
Several start with C. Insertion or edit?


```
  28701 AACCAAG
  22265 AACCGCA
2557682 AACCTGC
2693597 AACGACC
```


Our indexes are too similar to one another to allow for more than 1 simple difference before it is possible to be from multiple indexes.




