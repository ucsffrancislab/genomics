#!/usr/bin/env bash

#module load star/2.7.7a


#/francislab/data1/raw/20210205-EV_CATS/SFHH001A_S1_L001_R1_001.fastq.gz
#/francislab/data1/raw/20210205-EV_CATS/SFHH001B_S2_L001_R1_001.fastq.gz
#/francislab/data1/raw/20210205-EV_CATS/Undetermined_S0_L001_R1_001.fastq.gz

date=$( date "+%Y%m%d%H%M%S" )

#	uses python3 so need to run on C4

mkdir -p ${PWD}/output

for fastq in /francislab/data1/raw/20210205-EV_CATS/*.fastq.gz ; do

	basename=$( basename $fastq .fastq.gz )

	copy_umi_id=""
	f=${PWD}/output/${basename}_w_umi.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		copy_umi_id=$( sbatch --parsable --job-name=copy_umi_${basename} --time=60 --ntasks=2 --mem=15G \
			--partition common \
			--output=${PWD}/output/${basename}.copy_umi.${date}.txt \
			${PWD}/copy_umi.bash --threads 10 --umi-length 12 -i ${fastq} -o ${f} )
	fi

#	trim_id=""
#	f=${PWD}/output/${basename}_w_umi.trimmed.fastq.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		if [ ! -z ${trim_id} ] ; then
#			depend="--dependency=afterok:${copy_umi_id}"
#		else
#			depend=""
#		fi
#		#	gres=scratch should be about total needed divided by num threads
#		trim_id=$( sbatch ${depend} --parsable --job-name=cutadapt_${basename} --time=60 --ntasks=2 --mem=15G \
#			--output=${PWD}/output/${basename}.cutadapt.output.${date}.txt \
#			${PWD}/cutadapt.bash --trim-n --match-read-wildcards -u 16 -n 3 \
#				-a AGATCGGAAGAGCACACGTCTG -a AAAAAAAA -m 15 \
#				-o ${f} ${PWD}/output/${basename}_w_umi.fastq.gz )
#	fi


	trim_id=""
	f=${PWD}/output/${basename}_w_umi.trimmed.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${copy_umi_id} ] ; then
			depend="--dependency=afterok:${copy_umi_id}"
		else
			depend=""
		fi
		trim_id=$( sbatch ${depend} --parsable --job-name=bbduk_${basename} --time=60 --ntasks=2 --mem=15G \
			--partition common \
			--output=${PWD}/output/${basename}.bbduk.${date}.txt \
			~/.local/bin/bbduk.bash \
				-Xmx16g \
				in1=${PWD}/output/${basename}_w_umi.fastq.gz \
				out1=${f} \
				literal=AGATCGGA,AAAAAAAA \
				trimpolya=8 \
				ktrim=r \
				k=8 \
				mink=11 \
				hdist=1 \
				tbo \
				ordered=t \
				gcbins=auto \
				maq=20 \
				qtrim=w trimq=20 minavgquality=0 \
				minlength=15 )
			#	literal=TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC,AAAAAAAA \
			#	k=23 \
			#	maq=10 \
			#	qtrim=w trimq=5 minavgquality=0 \
		echo $trim_id
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
		if [ ! -z ${trim_id} ] ; then
			depend="--dependency=afterok:${trim_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=star-${basename} --time=480 --ntasks=8 --mem=62G \
			--partition common \
			--output=${PWD}/output/${basename}.sbatch.STAR.output.${date}.txt \
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




	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2salmonella.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${trim_id} ] ; then
			depend="--dependency=afterok:${trim_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=salmonella-${basename} --time=30 --ntasks=8 --mem=62G \
			--partition common \
			--output=${PWD}/output/${basename}.bowtie2.salmonella.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/salmonella \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f}
	fi

	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2burkholderia.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${trim_id} ] ; then
			depend="--dependency=afterok:${trim_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=burkholderia-${basename} --time=30 --ntasks=8 --mem=62G \
			--partition common \
			--output=${PWD}/output/${basename}.bowtie2.burkholderia.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/burkholderia \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f}
	fi



	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2phiX.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${trim_id} ] ; then
			depend="--dependency=afterok:${trim_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=phiX-${basename} --time=480 --ntasks=8 --mem=62G \
			--partition common \
			--output=${PWD}/output/${basename}.bowtie2phiX.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/phiX \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f}
	fi

	f=${PWD}/output/${basename}_w_umi.trimmed.STAR.mirna.Aligned.sortedByCoord.out.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${trim_id} ] ; then
			depend="--dependency=afterok:${trim_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=Smi-${basename} --time=480 --ntasks=8 --mem=62G \
			--partition common \
			--output=${PWD}/output/${basename}_w_umi.trimmed.STAR.mirna.${date}.txt \
			~/.local/bin/STAR.bash --runThreadN 8 --readFilesCommand zcat \
				--genomeDir /francislab/data1/refs/STAR/human_mirna \
				--readFilesIn ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz \
				--outSAMtype BAM SortedByCoordinate \
				--outSAMunmapped Within \
				--outFileNamePrefix ${PWD}/output/${basename}_w_umi.trimmed.STAR.mirna.
	fi

	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2.mirna.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${trim_id} ] ; then
			depend="--dependency=afterok:${trim_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=b2mi-${basename} --time=480 --ntasks=8 --mem=62G \
			--partition common \
			--output=${PWD}/output/${basename}.bowtie2.mirna.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/human_mirna \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f}
	fi

	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2.mirna.all.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${trim_id} ] ; then
			depend="--dependency=afterok:${trim_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=b2mia-${basename} --time=480 --ntasks=8 --mem=62G \
			--partition common \
			--output=${PWD}/output/${basename}.bowtie2.mirna.all.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --all --threads 8 -x /francislab/data1/refs/bowtie2/human_mirna \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f}
	fi

	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2.hg38.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${trim_id} ] ; then
			depend="--dependency=afterok:${trim_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=b2h-${basename} --time=480 --ntasks=8 --mem=62G \
			--partition common \
			--output=${PWD}/output/${basename}.bowtie2.hg38.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/hg38 \
			-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f}
	fi

	#	base=${PWD}/output/${basename}_w_umi.trimmed.bowtie2.hg38.all
	#	f=${base}.bam
	#	if [ -f $f ] && [ ! -w $f ] ; then
	#		echo "Write-protected $f exists. Skipping."
	#	else
	#		if [ ! -z ${trim_id} ] ; then
	#			depend="--dependency=afterok:${copy_umi_id}"
	#		else
	#			depend=""
	#		fi
	#
	#		threads=32
	#		fasta_size=$( stat --dereference --format %s ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz )
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
	#			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f}
	#	fi
	
		f=${PWD}/output/${basename}_w_umi.trimmed.bowtie.mirna.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=b1mi-${basename} --time=480 --ntasks=8 --mem=62G \
				--partition common \
				--output=${PWD}/output/${basename}.bowtie.mirna.${date}.txt \
				~/.local/bin/bowtie.bash --sam --threads 8 --sort \
				-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
				${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f}
		fi
	
		f=${PWD}/output/${basename}_w_umi.trimmed.bowtie.mirna.all.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=b1mia-${basename} --time=480 --ntasks=8 --mem=62G \
				--partition common \
				--output=${PWD}/output/${basename}.bowtie.mirna.all.${date}.txt \
				~/.local/bin/bowtie.bash --sam --all --threads 8 --sort \
				-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
				${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f}
		fi
	
	
		f=${PWD}/output/${basename}_w_umi.trimmed.blastn.nt.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=blast-${basename} --time=999 --ntasks=8 --mem=62G \
				--partition common \
				--output=${PWD}/output/${basename}.blastn.nt.${date}.txt \
				~/.local/bin/blastn.bash -num_threads 8 \
				-query ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz \
				-db /francislab/data1/refs/blastn/nt \
				-outfmt 6 \
				-out ${f}
		fi
	
		f=${PWD}/output/${basename}_w_umi.trimmed.diamond.nr.daa
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=d-${basename} --time=480 --ntasks=8 --mem=32G \
				--partition common \
				--output=${PWD}/output/${basename}.diamond.nr.${date}.txt \
				~/.local/bin/diamond.bash blastx --threads 8 \
					--query ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz \
					--db /francislab/data1/refs/diamond/nr \
					--evalue 0.1 \
					--outfmt 100 --out ${f}
		fi


done

