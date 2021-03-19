



Based on 20210205-EV_CATS/20210205-preprocessing

```BASH
./preprocess.bash



./postpreprocess.bash
```


----


```BASH
BOX="https://dav.box.com/dav/Francis _Lab_Share/20210310 20210309-EV_Lexogen 20210309-preprocessing"
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

```BASH
faSplit byname /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna.ACTG.fa human_mirna/
cat human_mirna/*fa > human_mirna.sorted.fa
```





```
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

sed -i '1s/_L001_R1_001.trimmed.underscored.burkholderia//g' post/index_counts.csv 
sed -i '1s/_L001_R1_001.trimmed.underscored.burkholderia//g' post/sindex_counts.csv 



python3 ~/.local/bin/merge_uniq-c.py --int --output all_family_counts.csv /francislab/data1/working/20210*/20210*-preprocessing/output/*family_counts
sed -i -e '1s/.trimmed.blastn.nt.species_genus_family.family_counts//g' -e '1s/_L001_R1_001//g' all_family_counts.csv
```




