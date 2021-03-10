



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
| Trimmed Read Count | 186108 | 135365 | 286165 | 184328 |
| Trimmed Ave Read Length | 88.3586 | 95.2554 | 83.6392 | 292.061 |
| STAR Aligned to Transcriptome | 13152 | 6603 | 12550 | 178 |
| STAR Aligned to Transcriptome % | 7.06 | 4.87 | 4.38 | .09 |
| STAR Aligned to Genome | 43133 | 28891 | 68679 | 832 |
| STAR Aligned to Genome % | 23.17 | 21.34 | 23.99 | .45 |
| STAR Unaligned | 142975 | 106474 | 217486 | 183496 |
| STAR Unaligned % | 76.82 | 78.65 | 76.00 | 99.54 |
| STAR Unmapped | 142975 | 106474 | 217486 | 183496 |
| STAR Unmapped % | 76.82 | 78.65 | 76.00 | 99.54 |
| Bowtie2 Aligned to hg38 (1) | 4849 | 1586 | 2826 | 860 |
| Bowtie2 Aligned to hg38 (1) % | 2.60 | 1.17 | .98 | .46 |
| STAR Aligned to mirna | 9651 | 6957 | 14663 | 189 |
| STAR Aligned to mirna % | 5.18 | 5.13 | 5.12 | .10 |
| Bowtie Aligned to mirna | 3882 | 1795 | 2891 | 53 |
| Bowtie Aligned to mirna % | 2.08 | 1.32 | 1.01 | .02 |
| Bowtie2 Aligned to mirna | 2006 | 857 | 1259 | 24 |
| Bowtie2 Aligned to mirna % | 1.07 | .63 | .43 | .01 |
| Bowtie2 Aligned to phiX | 35803 | 29816 | 50084 | 180035 |
| Bowtie2 Aligned to phiX % | 19.23 | 22.02 | 17.50 | 97.67 |
| RPH3A | 351 | 2394 | 7965 | 54 |
| ADGRG6 | 3280 | 2050 | 2910 | 60 |
| PLCE1 | 1968 | 1619 | 3533 | 18 |
| MAPT | 1580 | 1252 | 1600 | 10 |
| RARS2 | 1080 | 1000 | 2120 |  |
| CCDC151 | 1836 | 724 | 1240 | 16 |
| MIR486-2 | 1480 | 612 | 1316 | 22 |
| MIR486-1 | 1480 | 612 | 1316 | 22 |
| NOL4L | 1905 | 435 | 945 |  |
| GOLGA2P10 | 600 | 762 | 1296 |  |
| PIGG | 1134 | 612 | 666 | 12 |
| LOC100335030 | 577 | 481 | 1282 | 10 |
| MIRLET7BHG | 898 | 488 | 648 | 10 |
| RNA45SN2 | 969 | 357 | 683 | 7 |
| RNA45SN3 | 966 | 357 | 686 | 6 |
| VMP1 | 1090 | 380 | 510 | 10 |
| RNA45SN5 | 950 | 344 | 670 | 7 |
| RNA45SN1 | 950 | 344 | 667 | 7 |
| RNA45SN4 | 949 | 345 | 666 | 7 |
| KIF18B | 736 | 400 | 736 | 24 |
| RWDD2A | 882 | 266 | 679 | 21 |
| GREM2 | 324 | 360 | 852 | 6 |
| NOTCH2NLB | 707 | 332 | 427 | 7 |
| RNA28SN2 | 640 | 217 | 453 | 4 |
| RNA28SN3 | 636 | 217 | 456 | 3 |
| HASPIN | 604 | 278 | 416 | 6 |
| RNY4 | 651 | 156 | 461 | 9 |
| RNA28SN5 | 617 | 205 | 440 | 4 |
| RNA28SN4 | 618 | 205 | 436 | 4 |
| RNA28SN1 | 617 | 205 | 437 | 4 |
| KMT2D | 429 | 297 | 286 |  |
| EXOC7 | 799 | 68 | 102 |  |
| NACC2 | 338 | 240 | 372 | 10 |
| LOC727751 | 200 | 254 | 432 |  |
| LOC101929479 | 200 | 254 | 432 |  |
| PATL2 | 160 | 80 | 592 |  |
| PAIP1 | 393 | 172 | 240 | 6 |
| RRBP1 | 336 | 198 | 243 | 6 |
| BAZ2B | 215 | 301 | 258 |  |
| TUBGCP4 | 360 | 120 | 282 |  |
| FREM1 | 360 | 80 | 240 |  |
| MIRLET7F2 | 250 | 199 | 208 | 7 |
| SLC19A1 | 476 | 51 | 103 | 17 |
| MIRLET7A1 | 285 | 165 | 192 | 3 |
| MIRLET7A3 | 284 | 164 | 192 | 3 |
| MIRLET7A2 | 284 | 164 | 192 | 3 |
| MIRLET7F1 | 219 | 182 | 193 | 7 |
| RNA18SN4 | 272 | 120 | 195 | 3 |
| RNA18SN3 | 272 | 120 | 195 | 3 |
| RNA18SN2 | 272 | 120 | 195 | 3 |




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

