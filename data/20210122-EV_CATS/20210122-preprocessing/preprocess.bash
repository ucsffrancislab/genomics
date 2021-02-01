#!/usr/bin/env bash

module load star/2.7.7a


#/francislab/data1/raw/20210122-EV_CATS/SFHH001A_S1_L001_R1_001.fastq.gz
#/francislab/data1/raw/20210122-EV_CATS/SFHH001B_S2_L001_R1_001.fastq.gz
#/francislab/data1/raw/20210122-EV_CATS/Undetermined_S0_L001_R1_001.fastq.gz

#	*SFHH001A – index GCCAAT (index #6)
#	*SFHH001B – index CTTGTA (index #12)

#	uses python3 so need to run on C4

mkdir -p ${PWD}/output

for f in /francislab/data1/raw/20210122-EV_CATS/*.fastq.gz ; do

	basename=$( basename $f .fastq.gz )

	f=${PWD}/output/${basename}_w_umi.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		python3 bin/fumi_tools copy_umi --threads 10 --umi-length 12 \
			-i ${f} -o ${PWD}/output/${basename}_w_umi.fastq.gz
		chmod -w ${f}
	fi

	f=${PWD}/output/${basename}_w_umi.trimmed.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		cutadapt --trim-n --match-read-wildcards -u 16 -n 3 \
			-a AGATCGGAAGAGCACACGTCTG -a AAAAAAAA -m 15 \
			-o ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz ${PWD}/output/${basename}_w_umi.fastq.gz
		chmod -w ${f}
	fi

	#	#module load star/2.7.7a
	#	#	STAR --runMode genomeGenerate \
	#	#		--genomeFastaFiles /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa \
	#	#		--sjdbGTFfile /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
	#	#		--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a-49/ --runThreadN 32 --sjdbOverhang=49

	f=${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.sortedByCoord.out.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		sbatch --job-name=${basename}  --time=480 --ntasks=8 --mem=32G \
			--output=${PWD}/output/${basename}.sbatch.STAR.output.txt \
			~/.local/bin/STAR.bash --runThreadN 8 --readFilesCommand zcat \
				--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a-49/ \
				--sjdbGTFfile /francislab/data1/refs/fasta/hg38.ncbiRefSeq.gtf \
				--sjdbOverhang 49 \
				--readFilesIn ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz \
				--quantMode TranscriptomeSAM \
				--quantTranscriptomeBAMcompression -1 \
				--outSAMtype BAM SortedByCoordinate \
				--outSAMunmapped Within \
				--outFileNamePrefix ${PWD}/output/${basename}_w_umi.trimmed.STAR.
	fi




#	#	Unnecessary given the failing of the following step.
#	samtools sort -@ 10 -o ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.sorted.out.bam ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.out.bam

#	#	fumi_tools_dedup seems to need local compiling. Returns "Illegal Instruction"

#	echo ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.sorted.out.bam
#	python3 ~/.local/bin/fumi_tools dedup --threads 10 --memory 10G -i ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.sorted.out.bam -o ${PWD}/output/${basename}_deduplicated_transcriptome.bam 

#	echo ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.sortedByCoord.out.bam
#	python3 ~/.local/bin/fumi_tools dedup --threads 10 --memory 10G -i ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.sortedByCoord.out.bam -o ${PWD}/output/${basename}_deduplicated_genome.bam 

#	#	I don't have this executable and can't get passed the previous steps, so moot.
#	#rsem-calculate-expression -p 10 --strandedness forward --seed-length 15 --no-bam-output --alignments MySample_transcriptome_alignment.bam /transcriptomes/hg19/hg19 MySample

done

