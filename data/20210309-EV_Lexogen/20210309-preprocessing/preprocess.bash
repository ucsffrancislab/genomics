#!/usr/bin/env bash


#-r--r----- 1 gwendt francislab 60739202 Mar  9 14:02 SFHH003_S1_L001_R1_001.fastq.gz
#-r--r----- 1 gwendt francislab 49782061 Mar  9 14:02 SFHH004a_S2_L001_R1_001.fastq.gz
#-r--r----- 1 gwendt francislab 92698149 Mar  9 14:02 SFHH004b_S3_L001_R1_001.fastq.gz
#-r--r----- 1 gwendt francislab 37090622 Mar  9 14:02 Undetermined_S0_L001_R1_001.fastq.gz

date=$( date "+%Y%m%d%H%M%S" )

mkdir -p ${PWD}/output

for fastq in /francislab/data1/raw/20210309-EV_Lexogen/*.fastq.gz ; do

	basename=$( basename $fastq .fastq.gz )

	cutadapt_id=""
	f=${PWD}/output/${basename}.trimmed.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		#	gres=scratch should be about total needed divided by num threads
		cutadapt_id=$( sbatch ${depend} --parsable --job-name=cutadapt_${basename} --time=60 --ntasks=2 --mem=15G \
			--output=${PWD}/output/${basename}.cutadapt.${date}.txt \
			~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
				-a TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC -a AAAAAAAA -m 15 \
				-o ${f} ${fastq} )
#		Truseq Small RNA - TGGAATTCTCGGGTGCCAAGG
#		Lexogen - TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC
			#~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -u 16 -n 3 \
	fi

	#	#module load star/2.7.7a
	#	#	STAR --runMode genomeGenerate \
	#	#		--genomeFastaFiles /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa \
	#	#		--sjdbGTFfile /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ncbiRefSeq.gtf \
	#	#		--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a-49/ --runThreadN 32 --sjdbOverhang=49

	f=${PWD}/output/${basename}.trimmed.STAR.Aligned.sortedByCoord.out.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${cutadapt_id} ] ; then
			depend="--dependency=afterok:${cutadapt_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=STAR-${basename} --time=480 --ntasks=8 --mem=62G \
			--output=${PWD}/output/${basename}.STAR.hg38.${date}.txt \
			~/.local/bin/STAR.bash --runThreadN 8 --readFilesCommand zcat \
				--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a-49/ \
				--sjdbGTFfile /francislab/data1/refs/fasta/hg38.ncbiRefSeq.gtf \
				--sjdbOverhang 49 \
				--readFilesIn ${PWD}/output/${basename}.trimmed.fastq.gz \
				--quantMode TranscriptomeSAM \
				--quantTranscriptomeBAMcompression -1 \
				--outSAMtype BAM SortedByCoordinate \
				--outSAMunmapped Within \
				--outFileNamePrefix ${PWD}/output/${basename}.trimmed.STAR.
	fi




#	#	Unnecessary given the failing of the following step.
#	samtools sort -@ 10 -o ${PWD}/output/${basename}.trimmed.STAR.Aligned.toTranscriptome.sorted.out.bam ${PWD}/output/${basename}.trimmed.STAR.Aligned.toTranscriptome.out.bam

	f=${PWD}/output/${basename}.trimmed.bowtie2phiX.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${cutadapt_id} ] ; then
			depend="--dependency=afterok:${cutadapt_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=phix-${basename} --time=480 --ntasks=8 --mem=62G \
			--output=${PWD}/output/${basename}.bowtie2.phiX.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/phiX \
			--very-sensitive-local -U ${PWD}/output/${basename}.trimmed.fastq.gz -o ${f}
	fi

	f=${PWD}/output/${basename}.trimmed.STAR.mirna.Aligned.sortedByCoord.out.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${cutadapt_id} ] ; then
			depend="--dependency=afterok:${cutadapt_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=Smirna-${basename} --time=480 --ntasks=8 --mem=62G \
			--output=${PWD}/output/${basename}.trimmed.STAR.mirna.${date}.txt \
			~/.local/bin/STAR.bash --runThreadN 8 --readFilesCommand zcat \
				--genomeDir /francislab/data1/refs/STAR/human_mirna \
				--readFilesIn ${PWD}/output/${basename}.trimmed.fastq.gz \
				--outSAMtype BAM SortedByCoordinate \
				--outSAMunmapped Within \
				--outFileNamePrefix ${PWD}/output/${basename}.trimmed.STAR.mirna.
	fi

	f=${PWD}/output/${basename}.trimmed.bowtie2.mirna.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${cutadapt_id} ] ; then
			depend="--dependency=afterok:${cutadapt_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=b2mirna-${basename} --time=480 --ntasks=8 --mem=62G \
			--output=${PWD}/output/${basename}.bowtie2.mirna.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/human_mirna \
			--very-sensitive-local -U ${PWD}/output/${basename}.trimmed.fastq.gz -o ${f}
	fi

	f=${PWD}/output/${basename}.trimmed.bowtie2.mirna.all.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${cutadapt_id} ] ; then
			depend="--dependency=afterok:${cutadapt_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=b2all-${basename} --time=480 --ntasks=8 --mem=62G \
			--output=${PWD}/output/${basename}.bowtie2.mirna.all.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --all --threads 8 -x /francislab/data1/refs/bowtie2/human_mirna \
			--very-sensitive-local -U ${PWD}/output/${basename}.trimmed.fastq.gz -o ${f}
	fi

	f=${PWD}/output/${basename}.trimmed.bowtie2.hg38.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		sbatch ${depend} --job-name=bhg38-${basename} --time=480 --ntasks=8 --mem=62G \
			--output=${PWD}/output/${basename}.bowtie2.hg38.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 \
				-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
				--very-sensitive-local -U ${PWD}/output/${basename}.trimmed.fastq.gz -o ${f}
	fi

#	base=${PWD}/output/${basename}.trimmed.bowtie2.hg38.all
#	f=${base}.bam
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		if [ ! -z ${cutadapt_id} ] ; then
#			depend="--dependency=afterok:${cutadapt_id}"
#		else
#			depend=""
#		fi
#
#		threads=32
#		fasta_size=$( stat --dereference --format %s ${PWD}/output/${basename}.trimmed.fastq.gz )
#		#r2_size=$( stat --dereference --format %s ${r2} )
#		#index_size=$( du -sb ${index} | awk '{print $1}' )
#		#scratch=$( echo $(( ((${r1_size}+${r2_size}+${index_size})/${threads}/1000000000*11/10)+1 )) )
#		# Add 1 in case files are small so scratch will be 1 instead of 0.
#		# 11/10 adds 10% to account for the output
#
#		scratch=$( echo $(( ((${fasta_size}*10)/${threads}/1000000000*11/10)+1 )) )
#
#		echo "Using scratch:${scratch}"
#
#		#still failed due to time at 1920 minutes (32 hours)
#		sbatch ${depend} --job-name=${basename} --time=10000 --ntasks=${threads} --mem=250G \
#			--gres=scratch:${scratch}G --output=${base}.output.txt \
#			~/.local/bin/bowtie2_scratch.bash --all --threads ${threads} -x /francislab/data1/refs/bowtie2/hg38 \
#			--very-sensitive-local -U ${PWD}/output/${basename}.trimmed.fastq.gz -o ${f}
#	fi

	f=${PWD}/output/${basename}.trimmed.bowtie.mirna.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${cutadapt_id} ] ; then
			depend="--dependency=afterok:${cutadapt_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=b1mirna-${basename} --time=480 --ntasks=8 --mem=62G \
			--output=${PWD}/output/${basename}.bowtie.mirna.${date}.txt \
			~/.local/bin/bowtie.bash --sam --threads 8 --sort \
			-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
			${PWD}/output/${basename}.trimmed.fastq.gz -o ${f}
	fi

	f=${PWD}/output/${basename}.trimmed.bowtie.mirna.all.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${cutadapt_id} ] ; then
			depend="--dependency=afterok:${cutadapt_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=b1all-${basename} --time=480 --ntasks=8 --mem=62G \
			--output=${PWD}/output/${basename}.bowtie.mirna.all.${date}.txt \
			~/.local/bin/bowtie.bash --sam --all --threads 8 --sort \
			-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
			${PWD}/output/${basename}.trimmed.fastq.gz -o ${f}
	fi

done

