#!/usr/bin/env bash

module load star/2.7.7a


#/francislab/data1/raw/20210122-EV_CATS/SFHH001A_S1_L001_R1_001.fastq.gz
#/francislab/data1/raw/20210122-EV_CATS/SFHH001B_S2_L001_R1_001.fastq.gz
#/francislab/data1/raw/20210122-EV_CATS/Undetermined_S0_L001_R1_001.fastq.gz

#	*SFHH001A – index GCCAAT (index #6)
#	*SFHH001B – index CTTGTA (index #12)

#	uses python3 so need to run on C4

for f in /francislab/data1/raw/20210122-EV_CATS/*.fastq.gz ; do

	basename=$( basename $f .fastq.gz )

	#python3 bin/fumi_tools copy_umi --threads 10 --umi-length 12 \
	#	-i ${f} -o ${basename}_w_umi.fastq.gz

	#cutadapt --trim-n --match-read-wildcards -u 16 -n 3 \
	#	-a AGATCGGAAGAGCACACGTCTG -a AAAAAAAA -m 15 \
	#	-o ${basename}_w_umi.trimmed.fastq.gz ${basename}_w_umi.fastq.gz

	#module load star/2.7.7a
	#	STAR --runMode genomeGenerate \
	#		--genomeFastaFiles /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa \
	#		--sjdbGTFfile /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
	#		--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a/ --runThreadN 32


	STAR --runThreadN 30 --readFilesCommand zcat \
		--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq/ \
		--sjdbGTFfile /francislab/data1/refs/fasta/hg38.ncbiRefSeq.gtf \
		--sjdbOverhang 49 \
		--readFilesIn ${basename}_w_umi.trimmed.fastq.gz \
		--quantMode TranscriptomeSAM \
		--quantTranscriptomeBAMcompression -1 \
		--outSAMtype BAM SortedByCoordinate \
		--outSAMunmapped Within \
		--outFileNamePrefix ./${basename}_w_umi.trimmed.STAR.

	#samtools sort -@ 10 -o MySample_Aligned.toTranscriptome.sorted.out.bam MySample_Aligned.toTranscriptome.out.bam

	#fumi_tools dedup --threads 10 --memory 10G -i MySample_Aligned.toTranscriptome.sorted.out.bam -o MySample_deduplicated_transcriptome.bam fumi_tools dedup --threads 10 --memory 10G -i MySample_Aligned.sortedByCoord.out.bam -o MySample_deduplicated_genome.bam

	#rsem-calculate-expression -p 10 --strandedness forward --seed-length 15 --no-bam-output --alignments MySample_transcriptome_alignment.bam /transcriptomes/hg19/hg19 MySample

done

