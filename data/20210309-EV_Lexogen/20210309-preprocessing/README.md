



Based on 20210205-EV_CATS/20210205-preprocessing

```BASH
./preprocess.bash

samtools flags UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY
0xf04	3844	UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY

cd output/
ln -s /francislab/data1/raw/20210309-EV_Lexogen/SFHH003_S1_L001_R1_001.fastq.gz 
ln -s /francislab/data1/raw/20210309-EV_Lexogen/SFHH004a_S2_L001_R1_001.fastq.gz 
ln -s /francislab/data1/raw/20210309-EV_Lexogen/SFHH004b_S3_L001_R1_001.fastq.gz 
ln -s /francislab/data1/raw/20210309-EV_Lexogen/Undetermined_S0_L001_R1_001.fastq.gz 
cd ../


for f in output/*fastq.gz ; do
zcat $f | paste - - - - | wc -l > $f.read_count
zcat $f | paste - - - - | cut -f2 | awk '{l+=length($1);i++}END{print l/i}' > $f.average_length
done


for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' | sort | uniq -c | sort -rn > ${f}.transcript_count
done


transcript_gene=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv

for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' > ${f}.transcript_ids
awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' ${transcript_gene} \
  ${f}.transcript_ids | sort | uniq -c | sort -rn > ${f}.gene_count
done

awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' ${transcript_gene} \
  output/*.toTranscriptome.out.bam.transcript_ids \
  | sort | uniq -c | sort -rn > gene_count

awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' ${transcript_gene} \
  output/SFHH0*.toTranscriptome.out.bam.transcript_ids \
  | sort | uniq -c | sort -rn > determined_gene_count.txt


for f in ${PWD}/output/*unmapped.fasta.gz ; do
  base=${f%.fasta.gz}
  basename=$(basename $base)
  echo $f
  for m in 0 1 ; do

    sbatch --job-name=d-${basename}  --time=480 --ntasks=8 --mem=32G \
      --output=${base}.diamond.nr.masking${m}.output.txt \
      ~/.local/bin/diamond.bash blastx --query ${f} --threads 8 \
				--db /francislab/data1/refs/diamond/nr \
        --outfmt 100 --out ${base}.nr.masking${m}.daa --masking ${m}

done ; done


mirna_gff=/francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/hsa.v22.hg38.gff3

~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a ${mirna_gff} \
  -o STAR_mirna_miRNA_primary_transcript.tsv \
  output/*.trimmed.STAR.Aligned.sortedByCoord.out.bam > STAR_mirna_miRNA_primary_transcript.tsv.log 2>&1

~/.local/bin/featureCounts.bash -t miRNA -g Name -a ${mirna_gff} \
  -o STAR_mirna_miRNA.tsv \
  output/*.trimmed.STAR.Aligned.sortedByCoord.out.bam > STAR_mirna_miRNA.tsv.log 2>&1

~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a ${mirna_gff} \
  -o bowtie2_all_mirna_miRNA_primary_transcript.tsv \
  output/*.trimmed.bowtie2.hg38.all.bam > bowtie2_all_mirna_miRNA_primary_transcript.tsv.log 2>&1

~/.local/bin/featureCounts.bash -t miRNA -g Name -a ${mirna_gff} \
  -o bowtie2_all_mirna_miRNA.tsv \
  output/*.trimmed.bowtie2.hg38.all.bam > bowtie2_all_mirna_miRNA.tsv.log 2>&1

~/.local/bin/featureCounts.bash -t miRNA_primary_transcript -g Name -a ${mirna_gff} \
  -o bowtie2_mirna_miRNA_primary_transcript.tsv \
  output/*.trimmed.bowtie2.hg38.bam > bowtie2_mirna_miRNA_primary_transcript.tsv.log 2>&1

~/.local/bin/featureCounts.bash -t miRNA -g Name -a ${mirna_gff} \
  -o bowtie2_mirna_miRNA.tsv \
  output/*.trimmed.bowtie2.hg38.bam > bowtie2_mirna_miRNA.tsv.log 2>&1






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
./report.bash >> README.md
```







|    | SFHH003_R1 | SFHH004a_R1 | SFHH004b_R1 | Undetermined_R1 |
| --- | --- | --- | --- | --- |
| Raw Read Count | 291798 | 239036 | 449598 | 195013 |
| Raw Read Length | 301 | 301 | 301 | 301 |
| Trimmed Read Count | 291702 | 238965 | 449508 | 194999 |
| Trimmed Ave Read Length | 112.911 | 110.473 | 110.729 | 280.465 |
| STAR Aligned to Transcriptome | 23 | 9 | 13 | 3 |
| STAR Aligned to Transcriptome % | 0 | 0 | 0 | 0 |
| STAR Aligned to Genome | 306 | 83 | 213 | 61 |
| STAR Aligned to Genome % | .10 | .03 | .04 | .03 |
| STAR Unaligned | 291396 | 238882 | 449295 | 194938 |
| STAR Unaligned % | 99.89 | 99.96 | 99.95 | 99.96 |
| STAR Unmapped | 291396 | 238882 | 449295 | 194938 |
| STAR Unmapped % | 99.89 | 99.96 | 99.95 | 99.96 |
| Bowtie2 Aligned to hg38 (1) | 2508 | 608 | 1356 | 857 |
| Bowtie2 Aligned to hg38 (1) % | .85 | .25 | .30 | .43 |
| STAR Aligned to mirna | 11 | 6 | 9 | 2 |
| STAR Aligned to mirna % | 0 | 0 | 0 | 0 |
| Bowtie Aligned to mirna | 6 | 1 | 4 | 0 |
| Bowtie Aligned to mirna % | 0 | 0 | 0 | 0 |
| Bowtie2 Aligned to mirna | 1 | 1 | 0 | 1 |
| Bowtie2 Aligned to mirna % | 0 | 0 | 0 | 0 |
| Bowtie2 Aligned to phiX | 36115 | 30080 | 50514 | 180050 |
| Bowtie2 Aligned to phiX % | 12.38 | 12.58 | 11.23 | 92.33 |
| RIMKLB |  | 31 |  |  |
| GIGYF1 | 12 |  |  |  |
| ARHGEF11 | 11 |  |  |  |
| ZCWPW2 | 8 |  |  |  |
| ARRDC5 | 7 |  |  |  |
| PTCH1 | 6 |  |  |  |
| POLE | 6 |  |  |  |
| FZR1 |  |  | 6 |  |
| SUZ12 | 5 |  |  |  |
| KIAA0513 | 5 |  |  |  |
| ZNRF1 |  |  | 4 |  |
| UGT1A10 |  |  | 4 |  |
| STK17B |  | 4 |  |  |
| SHISA8 |  |  | 4 |  |
| CHMP1A | 4 |  |  |  |
| ND1 | 2 | 1 |  |  |
| LRRC41 |  |  |  | 3 |
| BRSK1 |  |  | 3 |  |
| TBL3 | 2 |  |  |  |
| RNY4 |  | 2 |  |  |
| PRAMENP |  |  | 2 |  |
| LOC729451 | 2 |  |  |  |
| AGO3 |  | 2 |  |  |
| AFG3L2 |  | 2 |  |  |
| UHRF1BP1L | 1 |  |  |  |
| TMEM185B |  | 1 |  |  |
| SUMO4 | 1 |  |  |  |
| STXBP5L | 1 |  |  |  |
| SKOR1 | 1 |  |  |  |
| SCG2 |  |  | 1 |  |
| PPBP | 1 |  |  |  |
| MEG3 |  |  | 1 |  |
| MARCH11-AS1 |  |  |  | 1 |
| LOC642366 | 1 |  |  |  |
| LOC107986162 |  |  | 1 |  |
| LOC105375863 |  |  | 1 |  |
| LOC105373896 |  | 1 |  |  |
| HBB |  | 1 |  |  |
| FRAT2 | 1 |  |  |  |
| COX1 | 1 |  |  |  |
| CBX8 |  |  |  | 1 |
| CARTPT | 1 |  |  |  |
| ATP6 | 1 |  |  |  |
| ACSS1 | 1 |  |  |  |





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

```BASH
python3 ./merge_uniq-c.py --int --output mirna_counts.csv output/*mirna_counts
```


Should perhaps sort fasta reference for easier viewing in IGV.
miRNA analysis. Compute median depth of coverage???
These regional alignments are all partial which seems unlikely.

```BASH
faSplit byname /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna.ACTG.fa human_mirna/
cat human_mirna/*fa > human_mirna.sorted.fa
```

