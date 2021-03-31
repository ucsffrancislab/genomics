#!/usr/bin/env bash

#alias sbatch="sbatch --mail-type=FAIL"

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

for r1 in /francislab/data1/raw/20191008_Stanford71/50_R1.fastq.gz ; do
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
#					trim_id=$( sbatch --parsable --job-name=cutadapt1_${basename} \
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
#					trim_id=$( sbatch --parsable --job-name=cutadapt2_${basename} \
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
					trim_id=$( sbatch --parsable --job-name=bbduk1_${basename} \
						--mail-type=FAIL \
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
					trim_id=$( sbatch --parsable --job-name=bbduk2_${basename} \
						--mail-type=FAIL \
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
					trim_id=$( sbatch --parsable --job-name=bbduk3_${basename} \
						--mail-type=FAIL \
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
#				--parsable \
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
						--mail-type=FAIL \
				--parsable \
				--output=${out_base}.${date}.txt \
				~/.local/bin/unpair_fastqs.bash -o ${f} ${in_base}_R?.fastq.gz ${in_base}_S.fastq.gz )
				#~/.local/bin/unpair_fastqs.bash -o ${f} ${in_base}_R?.fastq.gz )
			echo $unpair_id
		fi

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
						--mail-type=FAIL \
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
						--mail-type=FAIL \
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
						--mail-type=FAIL \
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
						--mail-type=FAIL \
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
						--mail-type=FAIL \
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
						--mail-type=FAIL \
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
						--mail-type=FAIL \
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
						--mail-type=FAIL \
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
						--mail-type=FAIL \
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
						--mail-type=FAIL \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie.bash --sam --all --threads 4 --sort \
				-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
				${in_base}.fastq.gz -o ${f}
		fi

#		out_base=${in_base}.blastn.nt
#		blast_id=""
#		f=${out_base}.txt.gz
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z ${unpair_id} ] ; then
#				depend="--dependency=afterok:${unpair_id}"
#			else
#				depend=""
#			fi
#			blast_id=$( sbatch ${depend} --job-name=blast-${basename} --time=999 --ntasks=8 --mem=120G \
#				--parsable \
#				--output=${out_base}.${date}.txt \
#				~/.local/bin/blastn.bash -num_threads 8 \
#				-query ${in_base}.fastq.gz \
#				-db /francislab/data1/refs/blastn/nt \
#				-outfmt 6 \
#				-out ${f} )
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

#		out_base=${in_base}.diamond.nr
#		f=${out_base}.daa
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z ${unpair_id} ] ; then
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

	done	#	for trimmer in bbduk1 bbduk2 cutadapt ; do

done	#	for fastq in /francislab/data1/raw/20210205-EV_CATS/*.fastq.gz ; do

