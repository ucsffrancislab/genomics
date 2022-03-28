#!/usr/bin/env bash


sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL --parsable "


#ll /francislab/data1/raw/20210428-EV/Hansen/S*fastq.gz


date=$( date "+%Y%m%d%H%M%S" )

#	uses python3 so need to run on C4

mkdir -p ${PWD}/output

for fastq in /francislab/data1/working/20210428-EV/20210511-trimming/trimmed/SFHH00*.fastq.gz ; do

	basename=$( basename $fastq .fastq.gz )
	#basename=${basename%%_*}

	ln -s ${fastq} output/${basename}.fastq.gz
	ln -s ${fastq}.read_count.txt output/${basename}.fastq.gz.read_count.txt
	ln -s ${fastq}.average_length.txt output/${basename}.fastq.gz.average_length.txt

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
					#	8bp
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="-u 16 -a AGATCGGA"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="-a TGGAATTC"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${basename}_${trimmer} \
						--time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -n 3 \
							${trim_options} -a AAAAAAAA -m 15 -o ${f} ${in_base}.fastq.gz )
							#-a TGGAATTC -a AAAAAAAA -m 15 -o ${f} ${in_base}.fastq.gz )
				fi
				;;

			cutadapt2)
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					#	14bp
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="-u 16 -a AGATCGGAAGAGCA"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="-a TGGAATTCTCGGGT"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${basename}_${trimmer} \
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
					#	22bp
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="-u 16 -a AGATCGGAAGAGCACACGTCTG"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="-a TGGAATTCTCGGGTGCCAAGGA"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${basename}_${trimmer} \
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
					#	8bp
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="literal=AGATCGGA,AAAAAAAA forcetrimleft=16"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="literal=TGGAATTC,AAAAAAAA"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${basename}_${trimmer} \
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
					#	14bp
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="literal=AGATCGGAAGAGCA forcetrimleft=16"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="literal=TGGAATTCTCGGGT"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${basename}_${trimmer} \
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
					#	22bp
					if [ ${labkit} == "D-plex" ] ; then
						trim_options="literal=AGATCGGAAGAGCACACGTCTG forcetrimleft=16"
					elif [ ${labkit} == "Lexogen" ] ; then
						trim_options="literal=TGGAATTCTCGGGTGCCAAGGA"
					else
						trim_options=""
					fi
					trim_id=$( ${sbatch} --parsable --job-name=${basename}_${trimmer} \
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

		t=${trimmer:0:1}${trimmer: -1}

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
			${sbatch} ${depend} --job-name=${basename}${t}star --time=480 --ntasks=8 --mem=62G \
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
			${sbatch} ${depend} --job-name=${basename}${t}salmonella --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/salmonella \
				--no-unal \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.salmonella.masked
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=${basename}${t}Msalmonella --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/salmonella.masked \
				--no-unal \
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
			${sbatch} ${depend} --job-name=${basename}${t}burkholderia --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/burkholderia \
				--no-unal \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.burkholderia.masked
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=${basename}${t}Mburkholderia --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/burkholderia.masked \
				--no-unal \
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
			${sbatch} ${depend} --job-name=${basename}${t}phiX --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/phiX \
				--no-unal \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}
		fi

		out_base=${in_base}.bowtie2.rmsk
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=${basename}${t}rmsk --time=999 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/rmsk \
				--no-unal \
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
			${sbatch} ${depend} --job-name=${basename}${t}Smi --time=30 --ntasks=4 --mem=30G \
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
			${sbatch} ${depend} --job-name=${basename}${t}b2mi --time=30 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 4 -x /francislab/data1/refs/bowtie2/human_mirna \
				--no-unal \
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
			${sbatch} ${depend} --job-name=${basename}${t}b2mia --time=60 --ntasks=4 --mem=30G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --all --threads 4 -x /francislab/data1/refs/bowtie2/human_mirna \
				--no-unal \
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
			${sbatch} ${depend} --job-name=${basename}${t}b2h --time=999 --ntasks=8 --mem=62G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 8 \
				-x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts \
				--no-unal \
				--very-sensitive-local -U ${in_base}.fastq.gz -o ${f}

				#	Accidentally included 2 indexes. Not sure what that does so rerunning.
				#-x /francislab/data1/refs/bowtie2/hg38 \
				
		fi

		out_base=${in_base}.bowtie2.mRNA_Prot
		f=${out_base}.bam
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${trim_id} ] ; then
				depend="--dependency=afterok:${trim_id}"
			else
				depend=""
			fi
			${sbatch} ${depend} --job-name=${basename}${t}rna --time=999 --ntasks=8 --mem=62G \
				--output=${out_base}.${date}.txt \
				~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/bowtie2/mRNA_Prot \
				--no-unal \
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
			${sbatch} ${depend} --job-name=${basename}${t}b1mi --time=30 --ntasks=4 --mem=30G \
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
			${sbatch} ${depend} --job-name=${basename}${t}b1mia --time=30 --ntasks=4 --mem=30G \
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

##	There is no --fast
##	--mid-sensitive          enable mid-sensitive mode (default: fast)
##	--sensitive              enable sensitive mode (default: fast)
##	--more-sensitive         enable more sensitive mode (default: fast)
##	--very-sensitive         enable very sensitive mode (default: fast)
##	--ultra-sensitive        enable ultra sensitive mode (default: fast)
#
#		diamond_id=""
#		out_base=${in_base}.diamond.nr
#		f=${out_base}.txt.gz
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z "${trim_id}" ] ; then
#				depend="--dependency=afterok:${trim_id}"
#			else
#				depend=""
#			fi
#
#			#diamond_id=$( ${sbatch} ${depend} --job-name=${basename}${t}dia --time=9999 --ntasks=8 --mem=60G \
#			#	--output=${f}.${date}.txt \
#			#	~/.local/bin/diamond.bash blastx --threads 8 \
#			#		--query ${in_base}.fastq.gz \
#			#		--db /francislab/data1/refs/diamond/nr \
#			#		--evalue 0.1 \
#			#		--outfmt 6 --out ${f} )
#
#			threads=8
#			db=/francislab/data1/refs/diamond/nr	#.dmnd
#			input=${in_base}.fastq.gz
#			db_size=$( stat --dereference --format %s ${db}.dmnd )
#
#			if [ -f ${input} ] ; then
#				input_size=$( stat --dereference --format %s ${input} )	#	output should be similar
#			else
#				#	biggest existing.
#				#input_size=17000000000
#				#input_size=10000000000
#                  # 5950036175
#				input_size=6000000000
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
#			diamond_id=$( ${sbatch} ${depend} --job-name=${basename}${t}dia --time=9999 --ntasks=${threads} --mem=60G \
#				--output=${f}.${date}.txt \
#				--gres=scratch:${scratch}G \
#				~/.local/bin/diamond_scratch.bash blastx --threads ${threads} \
#					--query ${input} \
#					--db ${db} \
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
#			#	Occassionally jobs fail, apparently due to out of disk space.
#			#	cp: failed to extend ‘/scratch/gwendt/105418/asgf.sqlite’: No space left on device
#			#	Others aren't properly requesting scratch space, or perhaps I'm doing this wrong.
#			#	Increase request size
#			#
#			#	I'm guessing that the number of threads is not relevant on C4?
#			#	This seems to be the case. Requesting 227GB each and running 11 on n17
#			#	Roughly 2.5TB and n17 has 2.6TB. Remove threads from all scratch calculations.
#			#
#			#index_size=$( du -sb ${index} | awk '{print $1}' )
#			#scratch=$( echo $(( (((3*${input_size})+${db_size})/${threads}/1000000000*20/10)+1 )) )
#			#scratch=$( echo $(( (((3*${input_size})+${db_size})/1000000000*13/10)+1 )) )
#			scratch=$( echo $(( (((2*${input_size})+${db_size})/1000000000*12/10)+1 )) )
#			# Add 1 in case files are small so scratch will be 1 instead of 0.
#			# 11/10 adds 10% to account for the output
#			# 12/10 adds 20% to account for the output
#
#			echo "Using scratch:${scratch}"
#
#			${sbatch} ${depend} --job-name=${basename}${t}sgf --time=999 --ntasks=${threads} --mem=30G \
#				--gres=scratch:${scratch}G \
#				--output=${out_base}.${date}.txt \
#				~/.local/bin/add_species_genus_family_to_blast_output_scratch.bash \
#					-db ${db} -input ${input}
#		fi  

	done	#	for trimmer in bbduk1 bbduk2 cutadapt1 cutadapt2 ; do

done	#	for fastq in /francislab/data1/raw/20210428-EV/Hansen/SFHH00*.fastq.gz ; do

