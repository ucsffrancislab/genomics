

```BASH
./preprocess.bash


./postpreprocess.bash
```



-----


ARCHIVE


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



```

for bam in output/*umi.sorted.consolidated*STAR.hg38.Aligned.sortedByCoord.out.bam; do

echo $bam
samtools view -F 3844 ${bam} | awk '{print length($10)}' > ${bam}.aligned_lengths
sort -n ${bam}.aligned_lengths | uniq -c > ${bam}.aligned_length_counts
samtools view -f 4    ${bam} | awk '{print length($10)}' > ${bam}.unaligned_lengths
sort -n ${bam}.unaligned_lengths | uniq -c > ${bam}.unaligned_length_counts
done


python3 ~/.local/bin/merge_uniq-c.py --seqint --int --output merged_aligned_length_counts.csv output/*.aligned_length_counts
sed -i -e '1s/.STAR.hg38.Aligned.sortedByCoord.out.bam.aligned_length_counts//g' -e '1s/.umi.sorted//g' merged_aligned_length_counts.csv


```







