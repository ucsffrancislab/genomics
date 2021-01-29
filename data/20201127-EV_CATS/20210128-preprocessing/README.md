

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

for f in output/*fastq.gz ; do
zcat $f | paste - - - - | wc -l > $f.read_count
zcat $f | paste - - - - | cut -f2 | awk '{l+=length($1);i++}END{print l/i}' > $f.average_length
done

for f in output/*out.bam ; do
samtools view -c -F 3844 $f > $f.aligned_count
done

./report.bash 
```



|    | L6_R1 | L6_R2 | L8_R1 | L8_R2 | Undetermined_R1 | Undetermined_R2 |
| --- | --- | --- | --- | --- | --- | --- |
| Raw Read Count | 453845 | 453845 | 454811 | 454811 | 25802 | 25802 |
| Raw Read Length | 151 | 151 | 151 | 151 | 151 | 151 |
| Trimmed Read Count | 209173 | 232875 | 164198 | 184385 | 22220 | 22401 |
| Trimmed Ave Read Length | 40.8046 | 36.4556 | 40.7141 | 36.7333 | 134.224 | 135.191 |
| STAR Aligned to Transcriptome | 15290 | 16549 | 22726 | 20099 | 259 | 250 |
| STAR Aligned to Genome | 89354 | 106931 | 94527 | 113189 | 1251 | 1534 |


