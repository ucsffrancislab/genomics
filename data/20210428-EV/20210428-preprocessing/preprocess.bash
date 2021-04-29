#!/usr/bin/env bash


sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --parsable "


#ll /francislab/data1/raw/20210428-EV/Hansen/S*fastq.gz


date=$( date "+%Y%m%d%H%M%S" )

#	uses python3 so need to run on C4

mkdir -p ${PWD}/output

#for fastq in /francislab/data1/raw/20210428-EV/Hansen/S*fastq.gz ; do
#for fastq in /francislab/data1/raw/20210428-EV/Hansen/SFHH005aa*.fastq.gz ; do
for fastq in /francislab/data1/raw/20210428-EV/Hansen/SFHH005[a-m]_*fastq.gz ; do


	basename=$( basename $fastq .fastq.gz )
	basename=${basename%%_*}

	ln -s ${fastq} output/${basename}.fastq.gz
	ln -s ${fastq}.read_count.txt output/${basename}.fastq.gz.read_count.txt

	echo $basename

	labkit=$( cat /francislab/data1/raw/20210428-EV/Hansen/${basename}.labkit )

	echo $labkit

	#	D-plex
	#	Lexogen

	for trimmer in bbduk1 bbduk2 bbduk3 cutadapt1 cutadapt2 cutadapt3 ; do
		echo Trimming with $trimmer

		in_base=${PWD}/output/${basename}
		out_base=${in_base}.${trimmer}

		trim_id=""
		f=${out_base}.fastq.gz

		#	NOTE that the CATS data contains a UMI that needs trimmed.

		case $trimmer in
			cutadapt1)
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="-u 16 -a AGATCGGA"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="-a TGGAATTC"
					else
						trim_options=""
					fi
				fi
					trim_id=$( ${sbatch} --parsable --job-name=${trimmer}_${basename} \
						--time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
							${trim_options} -a AAAAAAAA -m 15 -o ${f} ${in_base}.fastq.gz )
							#-a TGGAATTC -a AAAAAAAA -m 15 -o ${f} ${in_base}.fastq.gz )
				;;

			cutadapt2)
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="-u 16 -a AGATCGGAAGAGCA"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="-a TGGAATTCTCGGGT"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${trimmer}_${basename} \
						--time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
							${trim_options} -a AAAAAAAA -m 15 \
							-o ${f} ${in_base}.fastq.gz )
				fi
				;;

			cutadapt3)
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTG"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="-a TGGAATTCTCGGGTGCCAAGGA"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${trimmer}_${basename} \
						--time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
							${trim_options} -a AAAAAAAA -m 15 \
							-o ${f} ${in_base}.fastq.gz )
				fi
				;;

			bbduk1)
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="literal=AGATCGGA,AAAAAAAA forcetrimleft=16"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="literal=TGGAATTC,AAAAAAAA"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${trimmer}_${basename} \
						--time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/bbduk.bash \
							-Xmx16g \
							in1=${in_base}.fastq.gz \
							out1=${f} \
							${trim_options} \
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
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="literal=AGATCGGAAGAGCA forcetrimleft=16"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="literal=TGGAATTCTCGGGTG"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${trimmer}_${basename} \
						--time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/bbduk.bash \
							-Xmx16g \
							in1=${in_base}.fastq.gz \
							out1=${f} \
							${trim_options} \
							trimpolya=8 \
							ktrim=r \
							k=14 \
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
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="literal=AGATCGGAAGAGCACACGTCTG forcetrimleft=16"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="literal=TGGAATTCTCGGGTGCCAAGGAA"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${trimmer}_${basename} \
						--time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/bbduk.bash \
							-Xmx16g \
							in1=${in_base}.fastq.gz \
							out1=${f} \
							${trim_options} \
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

		esac

		in_base=${out_base}
		out_base=${in_base}.STAR.hg38
		f=${out_base}.Aligned.sortedByCoord.out.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=star-${basename} --time=480 --ntasks=8 --mem=62G \
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
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=salmonella-${basename} --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/salmonella \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.burkholderia
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=burkholderia-${basename} --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/burkholderia \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.phiX
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=phiX-${basename} --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/phiX \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.STAR.mirna
		f=${out_base}.Aligned.sortedByCoord.out.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=Smi-${basename} --time=30 --ntasks=4 --mem=30G \
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
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=b2mi-${basename} --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/human_mirna \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.mirna.all
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=b2mia-${basename} --time=60 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --all --threads 4 -x /francislab/data1/refs/bowtie2/human_mirna \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.hg38
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=b2h-${basename} --time=60 --ntasks=8 --mem=62G \
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
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=b1mi-${basename} --time=30 --ntasks=4 --mem=30G \
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
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=b1mia-${basename} --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie.bash --sam --all --threads 4 --sort \
				-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
				${in_base}.fastq.gz -o ${f}
		fi

#	#		out_base=${in_base}.blastn.nt
#	#		blast_id=""
#	#		f=${out_base}.txt.gz
#	#		if [ -f $f ] && [ ! -w $f ] ; then
#	#			echo "Write-protected $f exists. Skipping."
#	#		else
#	#			if [ ! -z ${trim_id} ] ; then
#	#				depend="--dependency=afterok:${trim_id}"
#	#			else
#	#				depend=""
#	#			fi
#	#			blast_id=$( ${sbatch} ${depend} --job-name=blast-${basename} --time=999 --ntasks=8 --mem=60G \
#	#				--parsable \
#	#				--output=${out_base}.${date}.txt \
#	#				~/.local/bin/blastn.bash -num_threads 8 \
#	#				-query ${in_base}.fastq.gz \
#	#				-db /francislab/data1/refs/blastn/nt \
#	#				-outfmt 6 \
#	#				-out ${f} )
#	#		fi
#	#	
#	#		out_base=${in_base}.blastn.nt.species_genus_family
#	#		f=${out_base}.txt.gz
#	#		if [ -f $f ] && [ ! -w $f ] ; then
#	#			echo "Write-protected $f exists. Skipping."
#	#		else
#	#			if [ ! -z ${blast_id} ] ; then
#	#				depend="--dependency=afterok:${blast_id}"
#	#			else
#	#				depend=""
#	#			fi  
#	#			${sbatch} ${depend} --job-name=sgf-${basename} --time=9999 --ntasks=4 --mem=30G \
#	#				--output=${out_base}.${date}.txt \
#	#				~/.local/bin/add_species_genus_family_to_blast_output.bash \
#	#					-input ${in_base}.blastn.nt.txt.gz
#	#		fi  
#	#
#	#		out_base=${in_base}.diamond.nr
#	#		f=${out_base}.daa
#	#		if [ -f $f ] && [ ! -w $f ] ; then
#	#			echo "Write-protected $f exists. Skipping."
#	#		else
#	#			if [ ! -z ${trim_id} ] ; then
#	#				depend="--dependency=afterok:${trim_id}"
#	#			else
#	#				depend=""
#	#			fi
#	#			${sbatch} ${depend} --job-name=d-${basename} --time=999 --ntasks=8 --mem=60G \
#	#				--output=${out_base}.${date}.txt \
#	#				~/.local/bin/diamond.bash blastx --threads 8 \
#	#					--query ${in_base}.fastq.gz \
#	#					--db /francislab/data1/refs/diamond/nr \
#	#					--evalue 0.1 \
#	#					--outfmt 100 --out ${f}
#	#		fi

#	There is no --fast
#	--mid-sensitive          enable mid-sensitive mode (default: fast)
#	--sensitive              enable sensitive mode (default: fast)
#	--more-sensitive         enable more sensitive mode (default: fast)
#	--very-sensitive         enable very sensitive mode (default: fast)
#	--ultra-sensitive        enable ultra sensitive mode (default: fast)

#		diamond_id=""
#		out_base=${in_base}.diamond.nr
#		f=${out_base}.txt.gz
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z "${unpair_id}" ] ; then
#				depend="--dependency=afterok:${unpair_id}"
#			else
#				depend=""
#			fi
#			#diamond_id=$( sbatch ${depend} --job-name=d-${basename} --time=9999 --ntasks=8 --mem=60G \
#			#	--mail-user=George.Wendt@ucsf.edu --mail-type=FAIL --parsable \
#			diamond_id=$( ${sbatch} ${depend} --job-name=d-${basename}-${trimmer} --time=9999 --ntasks=8 --mem=60G \
#				--output=${f}.${date}.txt \
#				~/.local/bin/diamond.bash blastx --threads 8 \
#					--query ${in_base}.fastq.gz \
#					--db /francislab/data1/refs/diamond/nr \
#					--evalue 0.1 \
#					--outfmt 6 --out ${f} )
#			echo $diamond_id
#		fi
#
#		out_base=${in_base}.diamond.nr.species_genus_family
#		f=${out_base}.txt.gz
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z "${diamond_id}" ] ; then
#				depend="--dependency=afterok:${diamond_id}"
#			else
#				depend=""
#			fi  
#
#			threads=4
#			db=/francislab/data1/refs/taxadb/asgf.sqlite
#			input=${in_base}.diamond.nr.txt.gz
#			db_size=$( stat --dereference --format %s ${db} )
#
#			if [ -f ${input} ] ; then
#				input_size=$( stat --dereference --format %s ${input} )	#	output should be similar
#			else
#				#	biggest existing.
#				#input_size=17000000000
#				input_size=10000000000
#			fi
#
#			#index_size=$( du -sb ${index} | awk '{print $1}' )
#			scratch=$( echo $(( (((3*${input_size})+${db_size})/${threads}/1000000000*12/10)+1 )) )
#			# Add 1 in case files are small so scratch will be 1 instead of 0.
#			# 11/10 adds 10% to account for the output
#			# 12/10 adds 20% to account for the output
#
#			echo "Using scratch:${scratch}"
#
#			${sbatch} ${depend} --job-name=sgf-${basename}-${trimmer} --time=999 --ntasks=${threads} --mem=30G \
#				--gres=scratch:${scratch}G \
#				--output=${out_base}.${date}.txt \
#				~/.local/bin/add_species_genus_family_to_blast_output_scratch.bash \
#					-db ${db} -input ${input}
#		fi  

	done	#	for trimmer in bbduk1 bbduk2 cutadapt1 cutadapt2 ; do

done	#	for fastq in /francislab/data1/raw/20210205-EV_CATS/*.fastq.gz ; do

