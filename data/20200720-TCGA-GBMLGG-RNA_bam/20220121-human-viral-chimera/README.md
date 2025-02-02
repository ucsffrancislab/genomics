



Chimeric pairs to the hg38 + doubly masked viral




```
python3 ~/.local/bin/merge_uniq-c.py --int -o merged.csv out/*nonchr_counts.txt
```



```
samtools merge -o merged.hg38viral.chimeric.bam out/*.hg38viral.chimeric.bam

samtools view -h merged.hg38viral.chimeric.bam | awk -F"\t" '( ( /^@/ ) || ( ( $3 ~ /^chr/ ) && ( $7 == "NC_038858.1" ) ) )' | samtools sort -o hg38.NC_038858.1.merged.hg38viral.chimeric.bam -
samtools view -h merged.hg38viral.chimeric.bam | awk -F"\t" '( ( /^@/ ) || ( ( $7 ~ /^chr/ ) && ( $3 == "NC_038858.1" ) ) )' | samtools sort -o NC_038858.1.hg38.merged.hg38viral.chimeric.bam -

samtools view -h merged.hg38viral.chimeric.bam | awk -F"\t" '( ( /^@/ ) || ( ( $3 ~ /^chr/ ) && ( $7 == "NC_001506.1" ) ) )' | samtools sort -o hg38.NC_001506.1.merged.hg38viral.chimeric.bam -
samtools view -h merged.hg38viral.chimeric.bam | awk -F"\t" '( ( /^@/ ) || ( ( $7 ~ /^chr/ ) && ( $3 == "NC_001506.1" ) ) )' | samtools sort -o NC_001506.1.hg38.merged.hg38viral.chimeric.bam -
```



```
samtools view -h merged.hg38viral.chimeric.bam | awk -F"\t" '( /^@/ ) || ( ( $3 == "chr14" ) && ( $7 == "NC_038858.1" ) ) || ( ( $3 == "NC_038858.1" ) && ( $7 == "chr14" ) )' | samtools sort -n -o NC_038858.1-and-chr14.merged.hg38viral.chimeric.bam -
samtools fastq -1 NC_038858.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz -2 NC_038858.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz NC_038858.1-and-chr14.merged.hg38viral.chimeric.bam
bowtie2.bash -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/chr14 -1 NC_038858.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz -2 NC_038858.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz --very-sensitive -o NC_038858.1-and-chr14.merged.hg38viral.chimeric.chr14.bam
bowtie2.bash -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts -1 NC_038858.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz -2 NC_038858.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz --very-sensitive -o NC_038858.1-and-chr14.merged.hg38viral.chimeric.hg38.chrXYM_alts.bam
 



samtools view -h merged.hg38viral.chimeric.bam | awk -F"\t" '( /^@/ ) || ( ( $3 == "chr14" ) && ( $7 == "NC_001506.1" ) ) || ( ( $3 == "NC_001506.1" ) && ( $7 == "chr14" ) )' | samtools sort -n -o NC_001506.1-and-chr14.merged.hg38viral.chimeric.bam -
samtools fastq -1 NC_001506.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz -2 NC_001506.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz NC_001506.1-and-chr14.merged.hg38viral.chimeric.bam
bowtie2.bash -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/chr14 -1 NC_001506.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz -2 NC_001506.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz --very-sensitive -o NC_001506.1-and-chr14.merged.hg38viral.chimeric.chr14.bam
bowtie2.bash -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_alts -1 NC_001506.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz -2 NC_001506.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz --very-sensitive -o NC_001506.1-and-chr14.merged.hg38viral.chimeric.hg38.chrXYM_alts.bam
```




```
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20220121-human-viral-chimera"
curl -netrc -X MKCOL "${BOX}/"
BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20220121-human-viral-chimera/inspect"
curl -netrc -X MKCOL "${BOX}/"

for f in *.merged.hg38viral.chimeric.bam* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
```



```
module load samtools bowtie2
samtools view -h merged.hg38viral.chimeric.bam | awk -F"\t" '( /^@/ ) || ( ( $3 == "chr14" ) && ( $7 == "NC_001506.1" ) ) || ( ( $3 == "NC_001506.1" ) && ( $7 == "chr14" ) )' | samtools sort -n -o NC_001506.1-and-chr14.merged.hg38viral.chimeric.bam -

samtools view -h merged.hg38viral.chimeric.bam | awk -F"\t" '( /^@/ ) || ( ( $3 == "chr14" ) && ( $7 == "NC_038858.1" ) ) || ( ( $3 == "NC_038858.1" ) && ( $7 == "chr14" ) )' | samtools sort -n -o NC_038858.1-and-chr14.merged.hg38viral.chimeric.bam -

samtools fastq -N -1 NC_001506.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz -2 NC_001506.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz NC_001506.1-and-chr14.merged.hg38viral.chimeric.bam

samtools fastq -N -1 NC_038858.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz -2 NC_038858.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz NC_038858.1-and-chr14.merged.hg38viral.chimeric.bam

abyss-pe name=NC_001506 K=16 k=96 B=2G in='NC_001506.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz NC_001506.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz'

abyss-pe name=NC_038858 K=16 k=96 B=2G in='NC_038858.1-and-chr14.merged.hg38viral.chimeric.R1.fastq.gz NC_038858.1-and-chr14.merged.hg38viral.chimeric.R2.fastq.gz'
```


```
~/github/dzerbino/velvet/velveth NC_038858.1/ 31 -fastq.gz NC_038858.1-and-chr14.merged.hg38viral.chimeric.R*
~/github/dzerbino/velvet/velvetg NC_038858.1/ 
 
~/github/dzerbino/velvet/velveth NC_001506.1/ 31 -fastq.gz NC_001506.1-and-chr14.merged.hg38viral.chimeric.R*
~/github/dzerbino/velvet/velvetg NC_001506.1/ 
```
