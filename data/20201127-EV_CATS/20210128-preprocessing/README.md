

```BASH
for f in /francislab/data1/raw/20201127-EV_CATS/output/[LU]*q.gz ; do
ln -s $f
done

for f in output/*R1_001.fastq.gz ; do
./CATS_trimming_r1.sh $f
done
for f in output/*R2_001.fastq.gz ; do
./CATS_trimming_r2.sh $f
done

module load star/2.7.7a

for f in /francislab/data1/working/20201127-EV_CATS/20210128-preprocessing/output/*.trimmed.fastq.gz ; do

	basename=$( basename $f .fastq.gz )

	sbatch --job-name=${basename}  --time=480 --ntasks=8 --mem=32G \
		--output=${PWD}/output/${basename}.sbatch.STAR.output.txt \
		~/.local/bin/STAR.bash --runThreadN 8 --readFilesCommand zcat \
			--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a-49/ \
			--sjdbGTFfile /francislab/data1/refs/fasta/hg38.ncbiRefSeq.gtf \
			--sjdbOverhang 49 \
			--readFilesIn ${f} \
			--quantMode TranscriptomeSAM \
			--quantTranscriptomeBAMcompression -1 \
			--outSAMtype BAM SortedByCoordinate \
			--outSAMunmapped Within \
			--outFileNamePrefix ${PWD}/output/${basename}.STAR.

done

for f in /francislab/data1/working/20201127-EV_CATS/20210128-preprocessing/output/*.trimmed.fastq.gz ; do

	basename=$( basename $f .fastq.gz )

	sbatch --job-name=${basename}  --time=480 --ntasks=8 --mem=32G \
		--output=${PWD}/output/${basename}.sbatch.bowtie2phiX.output.txt \
		~/.local/bin/bowtie2.bash --threads 8 -x /francislab/data1/refs/bowtie2/phiX --very-sensitive-local -U $f -o ${PWD}/output/${basename}.bowtie2phiX.bam

done

for f in output/*fastq.gz ; do
zcat $f | paste - - - - | wc -l > $f.read_count
zcat $f | paste - - - - | cut -f2 | awk '{l+=length($1);i++}END{print l/i}' > $f.average_length
done

for f in output/*out.bam ; do
samtools view -c -F 3844 $f > $f.aligned_count
done







for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' | sort | uniq -c | sort -rn > ${f}.transcript_count
done


for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' | sort | uniq -c | sort -rn > ${f}.transcript_count
done

for f in output/*.toTranscriptome.out.bam ; do
samtools view -F4 $f | awk '{print $3}' > ${f}.transcript_ids
awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv ${f}.transcript_ids | sort | uniq -c | sort -rn > ${f}.gene_count
done



awk '(NR==FNR){t2g[$1]=$2}(NR!=FNR){print t2g[$1]}' /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.transcript_gene.tsv output/*.toTranscriptome.out.bam.transcript_ids | sort | uniq -c | sort -rn > gene_count



./report.bash 
```


|    | L6_R1 | L6_R2 | L8_R1 | L8_R2 | Undetermined_R1 | Undetermined_R2 |
| --- | --- | --- | --- | --- | --- | --- |
| Raw Read Count | 453845 | 453845 | 454811 | 454811 | 25802 | 25802 |
| Raw Read Length | 151 | 151 | 151 | 151 | 151 | 151 |
| Trimmed Read Count | 209173 | 232875 | 164198 | 184385 | 22220 | 22401 |
| Trimmed Ave Read Length | 40.8046 | 36.4556 | 40.7141 | 36.7333 | 134.224 | 135.191 |
| STAR Aligned to Transcriptome | 15290 | 16549 | 22726 | 20099 | 259 | 250 |
| STAR Aligned to Transcriptome % | 7.30 | 7.10 | 13.84 | 10.90 | 1.16 | 1.11 |
| STAR Aligned to Genome | 89354 | 106931 | 94527 | 113189 | 1251 | 1534 |
| STAR Aligned to Genome % | 42.71 | 45.91 | 57.56 | 61.38 | 5.63 | 6.84 |
| Bowtie Aligned to phiX | 2111 | 53 | 2455 | 56 | 17470 | 3505 |
| Bowtie Aligned to phiX % | 1.00 | .02 | 1.49 | .03 | 78.62 | 15.64 |
| AK9 | 19170 | 108 | 49050 | 36 | 414 |  |
| ILDR2 | 1447 | 1367 | 7184 | 6656 | 88 | 72 |
| NUDT16P1 | 4852 | 10 | 10616 | 8 | 114 |  |
| RBM44 | 1431 | 1926 | 4086 | 4779 | 54 | 63 |
| MECP2 | 270 | 3329 | 390 | 6379 | 10 | 70 |
| L1CAM | 704 | 3040 | 904 | 4012 | 4 | 24 |
| NRXN3 | 5049 | 2102 | 700 | 350 |  |  |
| ANKRD36 | 1127 | 1225 | 2352 | 2793 |  |  |
| SLC1A2 | 144 | 2538 | 81 | 3474 |  | 45 |
| TCF12 | 2329 | 1824 | 1056 | 888 |  |  |
| ALG12 | 632 | 820 | 1808 | 2044 | 24 | 28 |
| ITIH5 | 36 | 1876 | 98 | 3182 |  | 30 |
| RNA45SN3 | 1092 | 1233 | 1144 | 1363 | 18 | 20 |
| RNA45SN2 | 1092 | 1232 | 1141 | 1362 | 18 | 20 |
| RNA45SN4 | 1091 | 1217 | 1142 | 1363 | 18 | 20 |
| HCFC1 | 2072 | 266 | 2191 | 280 | 35 |  |
| RNA45SN1 | 1089 | 1209 | 1143 | 1362 | 18 | 20 |
| RNA45SN5 | 1089 | 1209 | 1142 | 1362 | 18 | 20 |
| DGKH | 928 | 360 | 2114 | 1254 |  |  |
| ZNF460 |  | 1864 |  | 2692 |  | 30 |


