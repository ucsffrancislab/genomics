

```BASH
./preprocess.bash



./postpreprocess.bash

```



```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210205 20210205-EV_CATS 20210205-preprocessing"
curl -netrc -X MKCOL "${BOX}/"

for f in output/*daa ;do curl -netrc -T $f "${BOX}/" ; done
```


locally on my laptop
```BASH
for f in *daa ; do echo $f ;/Applications/MEGAN/tools/daa-meganizer --in ${f} --mapDB ~/megan/megan-map-Jul2020-2.db --threads 8; done
```


```
awk -F"\t" '(($7+$8+$9)>0)' *mirna_miRNA*tsv
```

```BASH
for f in output/*bowtie*bam ; do echo $f ; b=${f%.bam}; samtools sort -o ${b}.sorted.bam ${f}; samtools index ${b}.sorted.bam; done

for f in output/*{bam,bam.bai} ;do echo $f; curl -netrc -T $f "${BOX}/" ; done

curl -netrc -T /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna.ACTG.fa "${BOX}/"
```


Should perhaps sort fasta reference for easier viewing in IGV.
miRNA analysis. Compute median depth of coverage???
These regional alignments are all partial which seems unlikely.

```
faSplit byname /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna.ACTG.fa human_mirna/
cat human_mirna/*fa > human_mirna.sorted.fa
```








```BASH
for f in output/*.trimmed.fastq.gz ; do
echo $f
zcat ${f} | sed -n '1~4s/ /_/g;p' | gzip > ${f%.fastq.gz}.underscored.fastq.gz
done

for f in output/*.trimmed.underscored.fastq.gz ; do
echo $f
~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/burkholderia \
--very-sensitive-local -U ${f} -o ${f%.fastq.gz}.burkholderia.bam
done

for f in output/*trimmed.underscored.burkholderia.bam ; do
samtools view ${f} | awk '{print $1}' | awk -F: '{print $NF}' | sort | uniq -c > ${f%.bam}.all_index_counts
samtools view -F4 ${f} | awk '{print $1}' | awk -F: '{print $NF}' | sort | uniq -c > ${f%.bam}.aligned_index_counts
done

python3 ~/.local/bin/merge_uniq-c.py --int --output post/index_counts.csv output/*index_counts
python3 ~/.local/bin/merge_uniq-c.py --int --output post/sindex_counts.csv output/S*index_counts

sed -i '1s/_L001_R1_001_w_umi.trimmed.underscored.burkholderia//g' post/index_counts.csv 
sed -i '1s/_L001_R1_001_w_umi.trimmed.underscored.burkholderia//g' post/sindex_counts.csv 






for f in output/*trimmed.bowtie2burkholderia.bam ; do
samtools view ${f} | awk '{print $1}' | awk -F_ '{print $NF}' | sort | uniq -c > ${f%.bam}.all_umi_counts
samtools view -F4 ${f} | awk '{print $1}' | awk -F_ '{print $NF}' | sort | uniq -c > ${f%.bam}.aligned_umi_counts
done

python3 ~/.local/bin/merge_uniq-c.py --int --output post/umi_counts.csv output/*umi_counts
python3 ~/.local/bin/merge_uniq-c.py --int --output post/sumi_counts.csv output/S*umi_counts

sed -i '1s/_L001_R1_001_w_umi.trimmed.bowtie2burkholderia//g' post/umi_counts.csv 
sed -i '1s/_L001_R1_001_w_umi.trimmed.bowtie2burkholderia//g' post/sumi_counts.csv 
```





The consolidation only takes the last, or perhaps the shortest read? ( -k1,1 )
Sorting -k4,4 effectively sorts by read length

```
for f in output/*.trimmed.fastq.gz ; do
echo $f
zcat $f | awk '{if(((NR-1) % 4)==0){split($1,a,"_");split($2,b,":");print($0" "a[2]"_"b[4])}else{print}}' | gzip > ${f%.fastq.gz}.prededupe.fastq.gz
zcat ${f%.fastq.gz}.prededupe.fastq.gz | paste - - - - | sort -k3,3 -k4,4 | tr "\t" "\n" | gzip > ${f%.fastq.gz}.prededupe.sorted.fastq.gz
python3 ~/github/ucsffrancislab/umi/consolidate.py ${f%.fastq.gz}.prededupe.sorted.fastq.gz ${f%.fastq.gz}.prededupe.sorted.deduped.fastq 15 0.9
done
```


```
cat /francislab/data1/working/20210205-EV_CATS/20210205-preprocessing/output/SFHH001A_S1_L001_R1_001_w_umi.trimmed.prededupe.sorted.deduped.fastq | grep -A 1 "@GTATGGCAGAGG"
@GTATGGCAGAGG_GCCAAT_5 1:N:0:GCCAAT
GGGGTAGAATTCCACG
[gwendt@c4-log1 ~/github/ucsffrancislab/GECKO/ImportMatrix]$ zcat /francislab/data1/working/20210205-EV_CATS/20210205-preprocessing/output/SFHH001A_S1_L001_R1_001_w_umi.trimmed.prededupe.sorted.fastq.gz | grep -A 1 "_GTATGGCAGAGG"
@M02326:200:000000000-DBKBG:1:1101:12139:21999_GTATGGCAGAGG 1:N:0:GCCAAT GTATGGCAGAGG_GCCAAT
GGGGTAGAATTCCACGTGTAGCAG
--
@M02326:200:000000000-DBKBG:1:1101:14051:7836_GTATGGCAGAGG 1:N:0:GCCAAT GTATGGCAGAGG_GCCAAT
GGGGTAGAATTCCACGTGTAGCAGTGAAATGCGTAGAGATG
--
@M02326:200:000000000-DBKBG:1:1102:13674:12746_GTATGGCAGAGG 1:N:0:GCCAAT GTATGGCAGAGG_GCCAAT
GGGGTAGAATTCCACGTGTAGCAGT
--
@M02326:200:000000000-DBKBG:1:1102:24292:16010_GTATGGCAGAGG 1:N:0:GCCAAT GTATGGCAGAGG_GCCAAT
GGGGTAGAATTCCACGTGTAGCAGTGAAATGCGTAGAGATG
--
@M02326:200:000000000-DBKBG:1:1102:24808:15216_GTATGGCAGAGG 1:N:0:GCCAAT GTATGGCAGAGG_GCCAAT
GGGGTAGAATTCCACG
```


wk -F, '($2>5){print}' 20210315-bbuk-nodedup/post/sumi_counts.csv 
sequence,SFHH001A_S1.aligned_umi_counts,SFHH001A_S1.all_umi_counts,SFHH001B_S2.aligned_umi_counts,SFHH001B_S2.all_umi_counts
ACAGGCGATGAA,9,11,3,9
ACCAGTACCGTG,6,22,4,30
ACTGTCATGGTT,19,27,14,20
AGCATGCCGCGG,8,16,8,12
AGCCACACTGGG,19,34,25,37
AGTAGCTGGTCT,44,123,46,108
CAGCAATGCCGC,6,16,7,13
CCCCCTCGCCGT,8,15,3,4
CGGTGGTTCTGT,7,10,7,9
GAGTCGTCCTGC,37,61,25,38
GCAACCCTTGTC,9,17,3,7
GCCGGGTAGCTA,7,9,0,1
TACGGATGAAAG,58,123,28,49
TATCCATGGCCA,7,7,4,7

cat /francislab/data1/working/20210205-EV_CATS/20210205-preprocessing/output/SFHH001A_S1_L001_R1_001_w_umi.trimmed.prededupe.sorted.deduped.fastq | grep -A 1 "@AGTAGCTGGTCT"

zcat /francislab/data1/working/20210205-EV_CATS/20210205-preprocessing/output/SFHH001A_S1_L001_R1_001_w_umi.trimmed.prededupe.sorted.fastq.gz | grep -A 1 "_AGTAGCTGGTCT"
