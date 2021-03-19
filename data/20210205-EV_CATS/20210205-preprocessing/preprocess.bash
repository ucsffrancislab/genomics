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
			--output=${PWD}/output/${basename}.copy_umi.${date}.txt \
			${PWD}/copy_umi.bash --threads 10 --umi-length 12 -i ${fastq} -o ${f} )
		echo $copy_umi_id
	fi

	#	The umi length is 12, yet they have us remove 16 with cutadapt.

#	trim_id=""
#	f=${PWD}/output/${basename}_w_umi.trimmed.fastq.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		if [ ! -z ${copy_umi_id} ] ; then
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
#				#-a AGATCGGA -a AAAAAAAA -m 15 \
#	fi


	#	bbduk DOES NOT REMOVE THE UMI
	#	add forcetrimleft=16  ???

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
				forcetrimleft=12 \
				minlength=15 )
			#	literal=AGATCGGAAGAGCACACGTCTG \
			#	literal=AGATCGGA,AAAAAAAA \
			#	literal=TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC,AAAAAAAA \
			#	k=23 \
			#	maq=10 \
			#	qtrim=w trimq=5 minavgquality=0 \
			#	I think that the trimpolya requires that it be already at the end?
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
		starhg38_id=$( sbatch ${depend} --job-name=star-${basename} --time=480 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}.STAR.output.${date}.txt \
			~/.local/bin/STAR.bash --runThreadN 8 --readFilesCommand zcat \
				--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a-49/ \
				--sjdbGTFfile /francislab/data1/refs/fasta/hg38.ncbiRefSeq.gtf \
				--sjdbOverhang 49 \
				--readFilesIn ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz \
				--quantMode TranscriptomeSAM \
				--quantTranscriptomeBAMcompression -1 \
				--outSAMtype BAM SortedByCoordinate \
				--outSAMunmapped Within \
				--outFileNamePrefix ${PWD}/output/${basename}_w_umi.trimmed.STAR. )
		echo $starhg38_id
	fi

	f=${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.sortedByCoord.out.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${starhg38_id} ] ; then
			depend="--dependency=afterok:${starhg38_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=1dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
	fi


#	#	SORT STAR TRANSCRIPTOME
#	#	Unnecessary given the failing of the following step.
#	samtools sort -@ 10 -o ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.sorted.out.bam ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.out.bam

#	#	DEDUP STAR TRANSCRIPTOME
#	echo ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.sorted.out.bam
#	python3 ~/.local/bin/fumi_tools dedup --threads 10 --memory 10G -i ${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.sorted.out.bam -o ${PWD}/output/${basename}_deduplicated_transcriptome.bam 

	f=${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.out.sorted.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${starhg38_id} ] ; then
			depend="--dependency=afterok:${starhg38_id}"
		else
			depend=""
		fi
		sort_id=$( sbatch ${depend} --job-name=2dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--parsable \
			--output=${f%.bam}.${date}.txt \
			~/.local/bin/samtools_sort.bash -o ${f} ${f%.sorted.bam}.bam )
	fi

	f=${PWD}/output/${basename}_w_umi.trimmed.STAR.Aligned.toTranscriptome.out.sorted.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${sort_id} ] ; then
			depend="--dependency=afterok:${sort_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=3dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
	fi


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
		salmon_id=$( sbatch ${depend} --job-name=salmonella-${basename} --time=30 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}.bowtie2.salmonella.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/salmonella \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f} )
		echo $salmon_id
	fi

#	#	DEDUP
	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2salmonella.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${salmon_id} ] ; then
			depend="--dependency=afterok:${salmon_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=4dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
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
		burk_id=$( sbatch ${depend} --job-name=burkholderia-${basename} --time=30 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}.bowtie2.burkholderia.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/burkholderia \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f} )
		echo $burk_id
	fi

#	#	DEDUP
	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2burkholderia.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${burk_id} ] ; then
			depend="--dependency=afterok:${burk_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=5dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
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
		phix_id=$( sbatch ${depend} --job-name=phiX-${basename} --time=480 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}.bowtie2phiX.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/phiX \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f} )
		echo $phix_id
	fi

#	#	DEDUP
	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2phiX.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${phix_id} ] ; then
			depend="--dependency=afterok:${phix_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=6dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
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
		starmirna_id=$( sbatch ${depend} --job-name=Smi-${basename} --time=480 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}_w_umi.trimmed.STAR.mirna.${date}.txt \
			~/.local/bin/STAR.bash --runThreadN 8 --readFilesCommand zcat \
				--genomeDir /francislab/data1/refs/STAR/human_mirna \
				--readFilesIn ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz \
				--outSAMtype BAM SortedByCoordinate \
				--outSAMunmapped Within \
				--outFileNamePrefix ${PWD}/output/${basename}_w_umi.trimmed.STAR.mirna. )
		echo $starmirna_id
	fi

#	#	DEDUP
	f=${PWD}/output/${basename}_w_umi.trimmed.STAR.mirna.Aligned.sortedByCoord.out.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${starmirna_id} ] ; then
			depend="--dependency=afterok:${starmirna_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=7dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
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
		b2mirna_id=$( sbatch ${depend} --job-name=b2mi-${basename} --time=480 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}.bowtie2.mirna.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/human_mirna \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f} )
		echo $b2mirna_id
	fi

#	#	DEDUP
	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2.mirna.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${b2mirna_id} ] ; then
			depend="--dependency=afterok:${b2mirna_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=8dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
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
		b2mirnaall_id=$( sbatch ${depend} --job-name=b2mia-${basename} --time=480 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}.bowtie2.mirna.all.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --all --threads 8 -x /francislab/data1/refs/bowtie2/human_mirna \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f} )
		echo $b2mirnaall_id
	fi

#	#	DEDUP
	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2.mirna.all.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${b2mirnaall_id} ] ; then
			depend="--dependency=afterok:${b2mirnaall_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=9dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
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
		bhg38_id=$( sbatch ${depend} --job-name=b2h-${basename} --time=480 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}.bowtie2.hg38.${date}.txt \
			~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/hg38 \
			-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
			--very-sensitive-local -U ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f} )
		echo $bhg38_id
	fi

#	#	DEDUP
	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie2.hg38.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${bhg38_id} ] ; then
			depend="--dependency=afterok:${bhg38_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=0dd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
	fi


	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie.mirna.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${trim_id} ] ; then
			depend="--dependency=afterok:${trim_id}"
		else
			depend=""
		fi
		bmirna_id=$( sbatch ${depend} --job-name=b1mi-${basename} --time=480 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}.bowtie.mirna.${date}.txt \
			~/.local/bin/bowtie.bash --sam --threads 8 --sort \
			-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
			${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f} )
		echo $bmirna_id
	fi

#	#	DEDUP
	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie.mirna.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${bmirna_id} ] ; then
			depend="--dependency=afterok:${bmirna_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=Add-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
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
		bmirnaall_id=$( sbatch ${depend} --job-name=b1mia-${basename} --time=480 --ntasks=8 --mem=62G \
			--parsable \
			--output=${PWD}/output/${basename}.bowtie.mirna.all.${date}.txt \
			~/.local/bin/bowtie.bash --sam --all --threads 8 --sort \
			-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
			${PWD}/output/${basename}_w_umi.trimmed.fastq.gz -o ${f} )
		echo $bmirnaall_id
	fi

#	#	DEDUP
	f=${PWD}/output/${basename}_w_umi.trimmed.bowtie.mirna.all.deduped.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		if [ ! -z ${bmirnaall_id} ] ; then
			depend="--dependency=afterok:${bmirnaall_id}"
		else
			depend=""
		fi
		sbatch ${depend} --job-name=Bdd-${basename} --time=480 --ntasks=4 --mem=30G \
			--output=${f%.bam}.${date}.txt \
			${PWD}/dedup.bash --input-threads 4 \
				-i ${f%.deduped.bam}.bam -o ${f}
	fi







#	f=${PWD}/output/${basename}_w_umi.trimmed.blastn.nt.txt.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		if [ ! -z ${trim_id} ] ; then
#			depend="--dependency=afterok:${trim_id}"
#		else
#			depend=""
#		fi
#		blast_id=$( sbatch ${depend} --job-name=blast-${basename} --time=999 --ntasks=8 --mem=62G \
#			--parsable \
#			--output=${PWD}/output/${basename}.blastn.nt.${date}.txt \
#			~/.local/bin/blastn.bash -num_threads 8 \
#			-query ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz \
#			-db /francislab/data1/refs/blastn/nt \
#			-outfmt 6 \
#			-out ${f} )
#	fi
#
#	f=${PWD}/output/${basename}_w_umi.trimmed.blastn.nt.species_genus_family.txt.gz
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		if [ ! -z ${blast_id} ] ; then
#			depend="--dependency=afterok:${blast_id}"
#		else
#			depend=""
#		fi  
#		sbatch ${depend} --job-name=sgf-${basename} --time=99 --ntasks=2 --mem=15G \
#			--output=${f%.txt.gz}.${date}.txt \
#			~/.local/bin/add_species_genus_family_to_blast_output.bash -input ${f}
#	fi  
#
#	f=${PWD}/output/${basename}_w_umi.trimmed.diamond.nr.daa
#	if [ -f $f ] && [ ! -w $f ] ; then
#		echo "Write-protected $f exists. Skipping."
#	else
#		if [ ! -z ${trim_id} ] ; then
#			depend="--dependency=afterok:${trim_id}"
#		else
#			depend=""
#		fi
#		sbatch ${depend} --job-name=d-${basename} --time=480 --ntasks=8 --mem=32G \
#			--output=${PWD}/output/${basename}.diamond.nr.${date}.txt \
#			~/.local/bin/diamond.bash blastx --threads 8 \
#				--query ${PWD}/output/${basename}_w_umi.trimmed.fastq.gz \
#				--db /francislab/data1/refs/diamond/nr \
#				--evalue 0.1 \
#				--outfmt 100 --out ${f}
#	fi

done

