

```BASH
./preprocess.bash









samtools flags UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY
0xf04	3844	UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY


cd output
ln -s /francislab/data1/raw/20210205-EV_CATS/SFHH001A_S1_L001_R1_001.fastq.gz
ln -s /francislab/data1/raw/20210205-EV_CATS/SFHH001B_S2_L001_R1_001.fastq.gz
ln -s /francislab/data1/raw/20210205-EV_CATS/Undetermined_S0_L001_R1_001.fastq.gz
cd ..




for f in output/*fastq.gz ; do
zcat $f | paste - - - - | wc -l > $f.read_count
zcat $f | paste - - - - | cut -f2 | awk '{l+=length($1);i++}END{print l/i}' > $f.average_length
done



for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' | sort | uniq -c | sort -rn > ${f}.transcript_count
done

for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' > ${f}.transcript_ids
awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv ${f}.transcript_ids | sort | uniq -c | sort -rn > ${f}.gene_count
done

awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv output/*.toTranscriptome.out.bam.transcript_ids | sort | uniq -c | sort -rn > gene_count

awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv output/SFHH001*.toTranscriptome.out.bam.transcript_ids | sort | uniq -c | sort -rn > determined_gene_count.txt

for f in ${PWD}/output/*unmapped.fasta.gz ; do
  base=${f%.fasta.gz}
  basename=$(basename $base)
  echo $f
  for m in 0 1 ; do

    sbatch --job-name=${basename}  --time=480 --ntasks=8 --mem=32G \
      --output=${base}.diamond.nr.masking${m}.output.txt \
      ~/.local/bin/diamond.bash blastx --query ${f} --threads 8 --db /francislab/data1/refs/diamond/nr \
        --outfmt 100 --out ${base}.nr.masking${m}.daa --masking ${m}

done ; done

~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 -o STAR_mirna_miRNA_primary_transcript.tsv output/*_w_umi.trimmed.STAR.Aligned.sortedByCoord.out.bam > STAR_mirna_miRNA_primary_transcript.tsv.log 2>&1

~/.local/bin/featureCounts.bash -t miRNA -g Name -a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 -o STAR_mirna_miRNA.tsv output/*_w_umi.trimmed.STAR.Aligned.sortedByCoord.out.bam > STAR_mirna_miRNA.tsv.log 2>&1

~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 -o bowtie2_all_mirna_miRNA_primary_transcript.tsv output/*_w_umi.trimmed.bowtie2.hg38.all.bam > bowtie2_all_mirna_miRNA_primary_transcript.tsv.log 2>&1

~/.local/bin/featureCounts.bash -t miRNA -g Name -a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 -o bowtie2_all_mirna_miRNA.tsv output/*_w_umi.trimmed.bowtie2.hg38.all.bam > bowtie2_all_mirna_miRNA.tsv.log 2>&1

~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 -o bowtie2_mirna_miRNA_primary_transcript.tsv output/*_w_umi.trimmed.bowtie2.hg38.bam > bowtie2_mirna_miRNA_primary_transcript.tsv 2>&1

~/.local/bin/featureCounts.bash -t miRNA -g Name -a /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3 -o bowtie2_mirna_miRNA.tsv output/*_w_umi.trimmed.bowtie2.hg38.bam > bowtie2_mirna_miRNA.tsv.log 2>&1




for f in output/*STAR.mirna.Aligned.sortedByCoord.out.bam output/*.bowtie{2,}.mirna{.all,}.bam ; do
samtools view -F4 $f | awk '{print $3}' | sort | uniq -c | sort -rn > ${f}.mirna_counts
done

for f in output/*fasta.gz ; do
zcat $f | paste - - | wc -l > $f.read_count
done

for f in output/*.bam ; do
samtools view -c -F 3844 $f > $f.aligned_count
samtools view -c -f 4    $f > $f.unaligned_count
done

./report.bash 
./report.bash > report.md
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

python3 ./merge_uniq-c.py --int --output mirna_counts.csv output/*mirna_counts

python3 ./merge_uniq-c.py --int --output gene_counts.csv output/*gene_counts


Should perhaps sort fasta reference for easier viewing in IGV.
miRNA analysis. Compute median depth of coverage???
These regional alignments are all partial which seems unlikely.

```
faSplit byname /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna.ACTG.fa human_mirna/
cat human_mirna/*fa > human_mirna.sorted.fa
```


