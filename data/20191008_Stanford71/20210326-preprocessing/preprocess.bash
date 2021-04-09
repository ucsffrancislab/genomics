#!/usr/bin/env bash

#	this doesn't work as desired.
#	when collecting the job id, it is run in a subshell which doesn't keep aliases
#	perhaps put in .bashrc but not sure if that is sourced with slurm job
#alias sbatch="sbatch --mail-user=$( tail -n 1 ${HOME}/.forward ) --mail-type=FAIL --parsable "
#	Added to ~/.bash_profile
#	This doesn't work quite right. 

sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --parsable "

#	/francislab/data1/raw/20191008_Stanford71/01_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/02_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/03_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/04_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/05_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/06_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/07_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/08_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/09_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/10_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/11_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/12_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/13_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/14_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/15_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/16_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/17_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/18_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/19_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/20_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/21_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/22_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/23_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/24_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/25_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/26_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/27_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/28_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/29_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/30_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/31_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/32_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/33_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/34_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/35_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/36_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/37_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/38_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/39_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/40_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/41_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/42_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/43_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/44_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/45_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/46_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/47_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/48_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/49_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/50_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/51_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/52_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/53_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/54_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/55_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/56_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/57_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/58_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/59_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/60_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/61_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/62_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/63_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/64_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/65_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/66_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/67_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/68_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/69_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/70_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/71_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/72_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/73_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/74_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/75_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/76_R1.fastq.gz
#	/francislab/data1/raw/20191008_Stanford71/77_R1.fastq.gz

date=$( date "+%Y%m%d%H%M%S" )

#	uses python3 so need to run on C4

mkdir -p ${PWD}/output

for r1 in /francislab/data1/raw/20191008_Stanford71/??_R1.fastq.gz ; do
	r2=${r1/R1/R2}

	#ln -s $fastq output/
	ln -s $r1 output/
	ln -s $r2 output/

	basename=$( basename $r1 _R1.fastq.gz )

	#for trimmer in bbduk1 bbduk2 cutadapt1 cutadapt2 ; do
	for trimmer in bbduk1 bbduk2 bbduk3 ; do
		echo Trimming with $trimmer

		in_base=${PWD}/output/${basename}
		out_base=${in_base}.${trimmer}

		trim_id=""
		#f=${out_base}.fastq.gz
		f=${out_base}_R1.fastq.gz

		case $trimmer in
#			cutadapt1)
#				if [ -f $f ] && [ ! -w $f ] ; then
#					echo "Write-protected $f exists. Skipping."
#				else
#					trim_id=$( sbatch --job-name=cutadapt1_${basename} \
#						--time=60 --ntasks=2 --mem=15G \
#						--output=${out_base}.${date}.txt \
#						~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
#							-a TGGAATTC -a AAAAAAAA -m 15 \
#							-o ${f} ${in_base}.fastq.gz )
#						# -u 16
#				fi
#				;;
#
#			cutadapt2)
#				if [ -f $f ] && [ ! -w $f ] ; then
#					echo "Write-protected $f exists. Skipping."
#				else
#					trim_id=$( sbatch --job-name=cutadapt2_${basename} \
#						--time=60 --ntasks=2 --mem=15G \
#						--output=${out_base}.${date}.txt \
#						~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
#							-a TGGAATTCTCGGGTGCCAAGGA -a AAAAAAAA -m 15 \
#							-o ${f} ${in_base}.fastq.gz )
#						# -u 16
#				fi
#				;;

#	>Read1_adapter
#	AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
#	>Read2_adapter
#	AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT

			bbduk1)
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					trim_id=$( sbatch --job-name=bbduk1_${basename} \
						--time=99 --ntasks=4 --mem=30G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/bbduk.bash \
							-Xmx30g \
							in1=${r1} \
							in2=${r2} \
							out1=${out_base}_R1.fastq.gz \
							out2=${out_base}_R2.fastq.gz \
							outs=${out_base}_S.fastq.gz \
							ref=/francislab/data1/refs/fasta/illumina_adapters.fa \
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
					echo $trim_id
				fi
				;;

			bbduk2)
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					trim_id=$( sbatch --job-name=bbduk2_${basename} \
						--time=99 --ntasks=4 --mem=30G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/bbduk.bash \
							-Xmx30g \
							in1=${r1} \
							in2=${r2} \
							out1=${out_base}_R1.fastq.gz \
							out2=${out_base}_R2.fastq.gz \
							outs=${out_base}_S.fastq.gz \
							ref=/francislab/data1/refs/fasta/illumina_adapters.fa \
							trimpolya=8 \
							ktrim=r \
							k=20 \
							mink=11 \
							hdist=1 \
							tbo \
							ordered=t \
							gcbins=auto \
							maq=20 \
							qtrim=w trimq=20 minavgquality=0 \
							minlength=15 )
					echo $trim_id
				fi
				;;

			bbduk3)
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					trim_id=$( sbatch --job-name=bbduk3_${basename} \
						--time=99 --ntasks=4 --mem=30G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/bbduk.bash \
							-Xmx30g \
							in1=${r1} \
							in2=${r2} \
							out1=${out_base}_R1.fastq.gz \
							out2=${out_base}_R2.fastq.gz \
							outs=${out_base}_S.fastq.gz \
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
					echo $trim_id
				fi
				;;

		esac



#		in_base=${out_base}
#		out_base=${in_base}.length
#		f=${out_base}_R1.fastq.gz
#		length_id=""
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z ${trim_id} ] ; then
#				depend="--dependency=afterok:${trim_id}"
#			else
#				depend=""
#			fi
#			length_id=$( sbatch ${depend} --job-name=length-${basename} --time=30 --ntasks=4 --mem=30G \
#				--output=${out_base}.${date}.txt \
#				~/.local/bin/filter_paired_fastq_on_equal_read_length.bash \
#					${in_base}_R1.fastq.gz \
#					${in_base}_R2.fastq.gz \
#					${out_base}_R1.fastq.gz \
#					${out_base}_R2.fastq.gz \
#					${out_base}_diff_R1.fastq.gz \
#					${out_base}_diff_R2.fastq.gz )
#			echo $length_id
#		fi
	
		in_base=${out_base}
		out_base=${in_base}.unpaired
		unpair_id=""
		f=${out_base}.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
#			if [ ! -z ${length_id} ] ; then
#				depend="--dependency=afterok:${length_id}"
#			else
#				depend=""
#			fi
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			unpair_id=$( sbatch ${depend} --job-name=unpair-${basename} --time=99 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/unpair_fastqs.bash -o ${f} ${in_base}_R?.fastq.gz ${in_base}_S.fastq.gz )
				#~/.local/bin/unpair_fastqs.bash -o ${f} ${in_base}_R?.fastq.gz )
			echo $unpair_id
		fi

		fasta_id=$unpair_id
#		fasta_id=""
#		in_base=${out_base}
#		out_base=${in_base}
#		f=${out_base}.fasta
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z ${unpair_id} ] ; then
#				depend="--dependency=afterok:${unpair_id}"
#			else
#				depend=""
#			fi
#			fasta_id=$( sbatch ${depend} --job-name=fasta-${basename} --time=999 --ntasks=4 --mem=30G \
#				--output=${f}.${date}.txt \
#				${PWD}/fastq2fasta.bash ${in_base}.fastq.gz ${f} )
#			echo $fasta_id
#		fi

		in_base=${out_base}
		out_base=${in_base}.STAR.hg38
		f=${out_base}.Aligned.sortedByCoord.out.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=star-${basename} --time=999 --ntasks=8 --mem=62G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/STAR.bash --runThreadN 8 --readFilesCommand zcat \
					--genomeDir /francislab/data1/refs/STAR/hg38-golden-ncbiRefSeq-2.7.7a-49/ \
					--sjdbGTFfile /francislab/data1/refs/fasta/hg38.ncbiRefSeq.gtf \
					--sjdbOverhang 49 \
					--readFilesIn ${in_base}.fastq.gz \
					--quantMode TranscriptomeSAM \
					--quantTranscriptomeBAMcompression -1 \
					--outSAMtype BAM SortedByCoordinate \
					--outSAMunmapped Within \
					--outFileNamePrefix ${out_base}.
		fi

		out_base=${in_base}.bowtie2.salmonella
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=salmonella-${basename} --time=99 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/salmonella \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.burkholderia
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=burkholderia-${basename} --time=99 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/burkholderia \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.phiX
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=phiX-${basename} --time=99 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/phiX \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.STAR.mirna
		f=${out_base}.Aligned.sortedByCoord.out.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=Smi-${basename} --time=999 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/STAR.bash --runThreadN 4 --readFilesCommand zcat \
					--genomeDir /francislab/data1/refs/STAR/human_mirna \
					--readFilesIn ${in_base}.fastq.gz \
					--outSAMtype BAM SortedByCoordinate \
					--outSAMunmapped Within \
					--outFileNamePrefix ${out_base}.
		fi

		out_base=${in_base}.bowtie2.mirna
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=b2mi-${basename} --time=99 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/human_mirna \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.mirna.all
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=b2mia-${basename} --time=99 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --all --threads 4 -x /francislab/data1/refs/bowtie2/human_mirna \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.hg38
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=b2h-${basename} --time=999 --ntasks=8 --mem=62G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/hg38 \
				-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie.mirna
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=b1mi-${basename} --time=99 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie.bash --sam --threads 4 --sort \
				-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
				${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie.mirna.all
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${unpair_id} ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			sbatch ${depend} --job-name=b1mia-${basename} --time=99 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie.bash --sam --all --threads 4 --sort \
				-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
				${in_base}.fastq.gz -o ${f}
		fi



#	01 4 30 2
#	02 4 60 2
#	03 4 60 1
#	04 4 120 1
#	05 4 60 1 fasta
#	06 4 30 1 fasta
#	07 4 30 1 fasta
#	08 4 30 1 fasta
#	09 4 30 1 fasta
#	10 4 60 1 fasta	#	timeout
# all failed . 4, 9 and 10 still running one. Expect only 4 to maybe work
#	if we really need to run blastn, we'll need to split the files
#
#		out_base=${in_base}.blastn.nt
#		blast_id=""
#		f=${out_base}.txt.gz
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			#if [ ! -z "${unpair_id}" ] ; then
#			#	depend="--dependency=afterok:${unpair_id}"
#			if [ ! -z "${fasta_id}" ] ; then
#				depend="--dependency=afterok:${fasta_id}"
#			else
#				depend=""
#			fi
#			blast_id=$( sbatch ${depend} --job-name=blast-${basename} --time=999 --ntasks=4 --mem=60G \
#				--output=${out_base}.${date}.txt \
#				~/.local/bin/blastn.bash -num_threads 1 \
#				-query ${in_base}.fasta \
#				-db /francislab/data1/refs/blastn/nt \
#				-outfmt 6 \
#				-out ${f} )
#				#-query ${in_base}.fastq.gz \
#		fi
#	
#		out_base=${in_base}.blastn.nt.species_genus_family
#		f=${out_base}.txt.gz
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z ${blast_id} ] ; then
#				depend="--dependency=afterok:${blast_id}"
#			else
#				depend=""
#			fi  
#			sbatch ${depend} --job-name=sgf-${basename} --time=999 --ntasks=4 --mem=30G \
#				--output=${out_base}.${date}.txt \
#				~/.local/bin/add_species_genus_family_to_blast_output.bash \
#					-input ${in_base}.blastn.nt.txt.gz
#		fi  


#[gwendt@c4-dev3 /francislab/data1/working/20191008_Stanford71/20210326-preprocessing]$ diamond blastx --outfmt 6 --out output/07.bbduk1.unpaired.fastq.diamond.nr.txt.gz --query output/07.bbduk1.unpaired.fastq.gz --db /francislab/data1/refs/diamond/nr.dmnd --threads 8

#	01 - 4 30 0.1
#	02 - 8 60 0.1
#	03 - 8 60 10	timedout
#	04 - 8 60 10 --ultra-sensitive	timedout

#	Not entirely sure what the order is, but guessing the order listed is it.
#	There is no --fast
#	--mid-sensitive          enable mid-sensitive mode (default: fast)
#	--sensitive              enable sensitive mode (default: fast)
#	--more-sensitive         enable more sensitive mode (default: fast)
#	--very-sensitive         enable very sensitive mode (default: fast)
#	--ultra-sensitive        enable ultra sensitive mode (default: fast)
#					--ultra-sensitive \

		diamond_id=""
		out_base=${in_base}.diamond.nr
		f=${out_base}.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z "${unpair_id}" ] ; then
				depend="--dependency=afterok:${unpair_id}"
			else
				depend=""
			fi
			#diamond_id=$( sbatch ${depend} --job-name=d-${basename} --time=9999 --ntasks=8 --mem=60G \
			#	--mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --parsable \
			diamond_id=$( ${sbatch} ${depend} --job-name=d-${basename} --time=9999 --ntasks=8 --mem=60G \
				--output=${f}.${date}.txt \
				~/.local/bin/diamond.bash blastx --threads 8 \
					--query ${in_base}.fastq.gz \
					--db /francislab/data1/refs/diamond/nr \
					--evalue 0.1 \
					--outfmt 6 --out ${f} )
			echo $diamond_id
		fi

		out_base=${in_base}.diamond.nr.species_genus_family
		f=${out_base}.txt.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z "${diamond_id}" ] ; then
				depend="--dependency=afterok:${diamond_id}"
			else
				depend=""
			fi  

			threads=4
			db=/francislab/data1/refs/taxadb/asgf.sqlite
			input=${in_base}.diamond.nr.txt.gz
			db_size=$( stat --dereference --format %s ${db} )

			if [ -f ${input} ] ; then
				input_size=$( stat --dereference --format %s ${input} )	#	output should be similar
			else
				#	biggest existing.
				#input_size=17000000000
				input_size=10000000000
			fi

			#index_size=$( du -sb ${index} | awk '{print $1}' )
			scratch=$( echo $(( ((${input_size}+${input_size}+${db_size})/${threads}/1000000000*12/10)+1 )) )
			# Add 1 in case files are small so scratch will be 1 instead of 0.
			# 11/10 adds 10% to account for the output
			# 12/10 adds 20% to account for the output

			echo "Using scratch:${scratch}"

			${sbatch} ${depend} --job-name=sgf-${basename} --time=999 --ntasks=${threads} --mem=30G \
				--gres=scratch:${scratch}G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/add_species_genus_family_to_blast_output_scratch.bash \
					-db ${db} -input ${input}
		fi  



#		out_base=${in_base}.diamond.nr
#		f=${out_base}.daa
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z "${unpair_id}" ] ; then
#				depend="--dependency=afterok:${unpair_id}"
#			else
#				depend=""
#			fi
#			sbatch ${depend} --job-name=d-${basename} --time=999 --ntasks=8 --mem=60G \
#				--output=${out_base}.${date}.txt \
#				~/.local/bin/diamond.bash blastx --threads 8 \
#					--query ${in_base}.fastq.gz \
#					--db /francislab/data1/refs/diamond/nr \
#					--evalue 0.1 \
#					--outfmt 100 --out ${f}
#		fi


#	kraken2 --db /francislab/data1/refs/kraken2/abv --threads 4 --output output/01.bbduk3.unpaired.kraken2.abv.txt --report output/01.bbduk3.unpaired.kraken2.abv.report.txt --use-names output/01.bbduk3.unpaired.fastq.gz


	done	#	for trimmer in bbduk1 bbduk2 cutadapt ; do

done	#	for fastq in /francislab/data1/raw/20210205-EV_CATS/*.fastq.gz ; do

