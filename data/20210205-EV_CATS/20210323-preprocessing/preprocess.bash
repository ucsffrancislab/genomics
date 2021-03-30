#!/usr/bin/env bash

#/francislab/data1/raw/20210205-EV_CATS/SFHH001A_S1_L001_R1_001.fastq.gz
#/francislab/data1/raw/20210205-EV_CATS/SFHH001B_S2_L001_R1_001.fastq.gz
#/francislab/data1/raw/20210205-EV_CATS/Undetermined_S0_L001_R1_001.fastq.gz

date=$( date "+%Y%m%d%H%M%S" )

#	uses python3 so need to run on C4

mkdir -p ${PWD}/output

for fastq in /francislab/data1/raw/20210205-EV_CATS/*.fastq.gz ; do

	ln -s $fastq output/

	basename=$( basename $fastq .fastq.gz )

	for cons in consolidated unconsolidated ; do

		case $cons in
			consolidated)
				copy_umi_id=""
				in_base=${PWD}/output/${basename}	#	doesn't exist
				out_base=${in_base}.umi
				f=${out_base}.fastq.gz
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					#	my copy umi id so it is compatible with the consolidate script
					copy_umi_id=$( sbatch --parsable --job-name=copy_umi_${basename} --time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						${PWD}/copy_umi.bash -l 12 -i ${fastq} -o ${f} )
					echo $copy_umi_id
				fi

				#	The UMI is 12bp, followed by a 4bp Template-Motif that should be removed also.

				sort_umi_id=""
				in_base=${out_base}
				out_base=${in_base}.sorted
				f=${out_base}.fastq.gz
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ! -z ${copy_umi_id} ] ; then
						depend="--dependency=afterok:${copy_umi_id}"
					else
						depend=""
					fi
					sort_umi_id=$( sbatch ${depend} --parsable --job-name=sort_umi_${basename} \
						--time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						${PWD}/sort_by_umi.bash -i ${f%.sorted.fastq.gz}.fastq.gz -o ${f} )
					echo $sort_umi_id
				fi

				#	Consolidate by UMI ( must be sorted first )
				cons_umi_id=""
				in_base=${out_base}
				out_base=${in_base}.consolidated
				f=${out_base}.fastq.gz
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ! -z ${sort_umi_id} ] ; then
						depend="--dependency=afterok:${sort_umi_id}"
					else
						depend=""
					fi
					cons_umi_id=$( sbatch ${depend} --parsable --job-name=cons_umi_${basename} \
						--time=60 --ntasks=2 --mem=15G \
						--output=${out_base}.${date}.txt \
						${PWD}/consolidate.bash -i ${in_base}.fastq.gz -o ${f} )
					echo $cons_umi_id
				fi
				c_base=${PWD}/output/${basename}.umi.sorted.consolidated
				;;

			unconsolidated)
				#cons_umi_id=""
				cons_umi_id=${copy_umi_id}
				c_base=${PWD}/output/${basename}.umi
				;;
		esac



		for trimmer in bbduk1 bbduk2 cutadapt1 cutadapt2 ; do
			echo Trimming with $trimmer

			in_base=${c_base}
			out_base=${in_base}.${trimmer}

			trim_id=""
			f=${out_base}.fastq.gz

			#	Trim 16bp
			case $trimmer in
				cutadapt1)
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${cons_umi_id} ] ; then
							depend="--dependency=afterok:${cons_umi_id}"
						else
							depend=""
						fi
						trim_id=$( sbatch ${depend} --parsable --job-name=cutadapt1_${basename} \
							--time=60 --ntasks=2 --mem=15G \
							--output=${out_base}.${date}.txt \
							~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -u 16 -n 3 \
								-a AGATCGGA -a AAAAAAAA -m 15 \
								-o ${f} ${in_base}.fastq.gz )
					fi
					;;

				cutadapt2)
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${cons_umi_id} ] ; then
							depend="--dependency=afterok:${cons_umi_id}"
						else
							depend=""
						fi
						trim_id=$( sbatch ${depend} --parsable --job-name=cutadapt2_${basename} \
							--time=60 --ntasks=2 --mem=15G \
							--output=${out_base}.${date}.txt \
							~/.local/bin/cutadapt.bash --trim-n --match-read-wildcards -u 16 -n 3 \
								-a AGATCGGAAGAGCACACGTCTG -a AAAAAAAA -m 15 \
								-o ${f} ${in_base}.fastq.gz )
					fi
					;;

				bbduk1)
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${cons_umi_id} ] ; then
							depend="--dependency=afterok:${cons_umi_id}"
						else
							depend=""
						fi
						trim_id=$( sbatch ${depend} --parsable --job-name=bbduk1_${basename} \
							--time=60 --ntasks=2 --mem=15G \
							--output=${out_base}.${date}.txt \
							~/.local/bin/bbduk.bash \
								-Xmx16g \
								in1=${in_base}.fastq.gz \
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
								forcetrimleft=16 \
								minlength=15 )
						echo $trim_id
					fi
					;;

				bbduk2)
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${cons_umi_id} ] ; then
							depend="--dependency=afterok:${cons_umi_id}"
						else
							depend=""
						fi
						trim_id=$( sbatch ${depend} --parsable --job-name=bbduk2_${basename} \
							--time=60 --ntasks=2 --mem=15G \
							--output=${out_base}.${date}.txt \
							~/.local/bin/bbduk.bash \
								-Xmx16g \
								in1=${in_base}.fastq.gz \
								out1=${f} \
								literal=AGATCGGAAGAGCACACGTCTG \
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
								forcetrimleft=16 \
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
				sbatch ${depend} --job-name=star-${basename} --time=480 --ntasks=8 --mem=62G \
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
				sbatch ${depend} --job-name=salmonella-${basename} --time=30 --ntasks=4 --mem=30G \
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
				sbatch ${depend} --job-name=burkholderia-${basename} --time=30 --ntasks=4 --mem=30G \
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
				sbatch ${depend} --job-name=phiX-${basename} --time=30 --ntasks=4 --mem=30G \
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
				sbatch ${depend} --job-name=Smi-${basename} --time=30 --ntasks=4 --mem=30G \
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
				sbatch ${depend} --job-name=b2mi-${basename} --time=30 --ntasks=4 --mem=30G \
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
				sbatch ${depend} --job-name=b2mia-${basename} --time=60 --ntasks=4 --mem=30G \
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
				sbatch ${depend} --job-name=b2h-${basename} --time=60 --ntasks=8 --mem=62G \
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
				sbatch ${depend} --job-name=b1mi-${basename} --time=30 --ntasks=4 --mem=30G \
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
				sbatch ${depend} --job-name=b1mia-${basename} --time=30 --ntasks=4 --mem=30G \
					--output=${out_base}.${date}.txt \
					~/.local/bin/bowtie.bash --sam --all --threads 4 --sort \
					-x /francislab/data1/refs/sources/mirbase.org/pub/mirbase/CURRENT/human_mirna \
					${in_base}.fastq.gz -o ${f}
			fi

			out_base=${in_base}.blastn.nt
			blast_id=""
			f=${out_base}.txt.gz
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${trim_id} ] ; then
					depend="--dependency=afterok:${trim_id}"
				else
					depend=""
				fi
				blast_id=$( sbatch ${depend} --job-name=blast-${basename} --time=999 --ntasks=8 --mem=60G \
					--parsable \
					--output=${out_base}.${date}.txt \
					~/.local/bin/blastn.bash -num_threads 8 \
					-query ${in_base}.fastq.gz \
					-db /francislab/data1/refs/blastn/nt \
					-outfmt 6 \
					-out ${f} )
			fi
		
			out_base=${in_base}.blastn.nt.species_genus_family
			f=${out_base}.txt.gz
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${blast_id} ] ; then
					depend="--dependency=afterok:${blast_id}"
				else
					depend=""
				fi  
				sbatch ${depend} --job-name=sgf-${basename} --time=9999 --ntasks=4 --mem=30G \
					--output=${out_base}.${date}.txt \
					~/.local/bin/add_species_genus_family_to_blast_output.bash \
						-input ${in_base}.blastn.nt.txt.gz
			fi  
		
			out_base=${in_base}.diamond.nr
			f=${out_base}.daa
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${trim_id} ] ; then
					depend="--dependency=afterok:${trim_id}"
				else
					depend=""
				fi
				sbatch ${depend} --job-name=d-${basename} --time=999 --ntasks=8 --mem=60G \
					--output=${out_base}.${date}.txt \
					~/.local/bin/diamond.bash blastx --threads 8 \
						--query ${in_base}.fastq.gz \
						--db /francislab/data1/refs/diamond/nr \
						--evalue 0.1 \
						--outfmt 100 --out ${f}
			fi

		done	#	for trimmer in bbduk1 bbduk2 cutadapt ; do

	done	#	for cons in consolidated unconsolidated ; do

done	#	for fastq in /francislab/data1/raw/20210205-EV_CATS/*.fastq.gz ; do

