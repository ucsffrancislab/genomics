#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
KALLISTO=${REFS}/kallisto
SUBREAD=${REFS}/subread
BOWTIE2=${REFS}/bowtie2
BLASTDB=${REFS}/blastn
KRAKEN2=${REFS}/kraken2
DIAMOND=${REFS}/diamond
STAR=${REFS}/STAR

#	do exported variables get passed to submitted jobs? No
#export BOWTIE2_INDEXES=/francislab/data1/refs/bowtie2
#export BLASTDB=/francislab/data1/refs/blastn
vmem=8
threads=8

date=$( date "+%Y%m%d%H%M%S" )


#
#	NOTE: This data is all Paired RNA
#

BASEDIR=/francislab/data1/working/20200320_Raleigh_Meningioma_RNA/20200320-viral_expression/trimmed


for r1 in ${BASEDIR}/020.fastq.gz ; do
#for r1 in ${BASEDIR}/001.fastq.gz ; do

	#r2=${r1/_R1/_R2}

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )

	for ref in hg38  ; do

		outbase="${base}.STAR.${ref}"
		starid=""
		f="${outbase}.Aligned.out.bam"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
			starid=$( qsub -N ${jobbase}.${ref} -l nodes=1:ppn=${threads} -l vmem=32gb \
				-j oe -o ${outbase}.${date}.out.txt \
				~/.local/bin/STAR.bash \
				-F "--runMode alignReads \
					--outFileNamePrefix ${outbase}. \
					--outSAMtype BAM Unsorted \
					--genomeDir ${STAR}/${ref} \
					--runThreadN ${threads} \
					--outSAMattrRGline ID:${jobbase} SM:${jobbase} \
					--readFilesCommand zcat \
					--outReadsUnmapped Fastx \
					--readFilesIn ${r1}" )
			echo "${starid}"
		fi

		infile="${base}.STAR.${ref}.Unmapped.out.R1.fastq.gz"

		#	Count so can normalize
		#
		#	count_fastq_reads.bash *Unmapped.out.R1.fastq.gz
		#
		f="${base}.STAR.${ref}.Unmapped.out.R1.fastq.gz.read_count.txt"
		unmapped_read_count=''
		if [ -f $f ] && [ ! -w $f ] ; then
			unmapped_read_count=$( cat ${f} )
			echo "Unmapped Count :${unmapped_read_count}:"
		fi


		for dref in nr viral ; do

			diamondid=""
			outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${dref}"
			f="${outbase}.csv.gz"
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${starid} ] ; then
					depend="-W depend=afterok:${starid}"
				else
					depend=""
				fi
				#	-e ${outbase}.err.txt \
				diamondid=$( qsub ${depend} -N ${jobbase}.${dref} -l nodes=1:ppn=8 -l vmem=16gb \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/diamond_scratch.bash \
						-F "blastx --db ${DIAMOND}/${dref} \
							--query ${infile} --outfmt 6 --out ${f}" )
						#-F "blastx --threads 8 --db ${DIAMOND}/${dref} \
				echo $diamondid
			fi

			input=${f}
			outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${dref}.summary"
			f1="${outbase}.sum-species.normalized.txt.gz"
			f2="${outbase}.sum-genus.normalized.txt.gz"
			if [ -f $f1 ] && [ ! -w $f1 ] && [ -f $f2 ] && [ ! -w $f2 ] ; then
				echo "Write-protected $f1 and $f2 exists. Skipping."
			else
				if [ ! -z ${diamondid} ] ; then
					depend="-W depend=afterok:${diamondid}"
				else
					depend=""
				fi

				#		SUMMARIZE AND NORMALIZE IN ONE SCRIPT ON SCRATCH
				#		MINIMIZE PIPING TO MINIMIZE MEMORY

				#	-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \

#					-l feature=nocommunal \
#					-l gres=scratch:50 \
				qsub ${depend} -N ${jobbase}.s.${dref} \
					-l feature=nocommunal \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/blastn_summarize_and_normalize_scratch.bash -F "\
						--db /francislab/data1/refs/taxadb/taxadb_full_nr.sqlite --accession nr \
						--input ${input} \
						--levels species,genus \
						--unmapped_read_count '${unmapped_read_count}'"
						#--input ${base}.STAR.${ref}.unmapped.diamond.${dref}.csv.gz \
			fi
	
		done	#	for d in nr viral ; do

		for bref in viral.masked ; do

			blastnid=""
			outbase="${base}.STAR.${ref}.Unmapped.out.blastn.${bref}"
			f="${outbase}.csv.gz"
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${starid} ] ; then
					depend="-W depend=afterok:${starid}"
				else
					depend=""
				fi
				#	-l nodes=1:ppn=${threads} -l vmem=16gb \
				#	-e ${outbase}.err.txt \
				blastnid=$( qsub ${depend} -N ${jobbase}.${bref} \
					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/blastn.bash \
						-F "-num_threads ${threads} -db ${BLASTDB}/${bref} \
							-query ${infile} -outfmt 6 -out ${f}" )
				echo $blastnid
			fi
			input=${f}

			outbase="${base}.STAR.${ref}.Unmapped.out.blastn.${bref}.summary"
			f1="${outbase}.sum-species.normalized.txt.gz"
			f2="${outbase}.sum-genus.normalized.txt.gz"
			if [ -f $f1 ] && [ ! -w $f1 ] && [ -f $f2 ] && [ ! -w $f2 ] ; then
				echo "Write-protected $f1 and $f2 exists. Skipping."
			else
				if [ ! -z ${blastnid} ] ; then
					depend="-W depend=afterok:${blastnid}"
				else
					depend=""
				fi

				#		SUMMARIZE AND NORMALIZE IN ONE SCRIPT ON SCRATCH
				#		MINIMIZE PIPING TO MINIMIZE MEMORY

				#	-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \

#					-l feature=nocommunal \
#					-l gres=scratch:50 \
				qsub ${depend} -N ${jobbase}.s.${bref} \
					-l feature=nocommunal \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/blastn_summarize_and_normalize_scratch.bash -F "\
						--input ${input} \
						--levels species,genus \
						--unmapped_read_count '${unmapped_read_count}'"
						#--input ${base}.STAR.${ref}.unmapped.diamond.${dref}.csv.gz \
			fi
	
		done	#	for bref in viral.masked ; do

	done	#	for ref in hg38  ; do


	bowtie2hkleid=""
	outbase="${base}.bowtie2-e2e.SVAs_and_HERVs_KWHE"
	f=${outbase}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		bowtie2hkleid=$( qsub -N ${jobbase}.HKLE.bt -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.${date}.out.txt \
			~/.local/bin/bowtie2.bash \
			-F "--xeq --threads ${threads} --very-sensitive -x ${BOWTIE2}/SVAs_and_HERVs_KWHE \
				--no-unal --rg-id ${jobbase} --rg "SM:${jobbase}" -U ${r1} -o ${outbase}.bam --sort")
		echo $bowtie2hkleid
	fi

	for q in 00 15 30 ; do
		outbase="${base}.bowtie2-e2e.SVAs_and_HERVs_KWHE.q${q}.counts"
		f="${outbase}.txt.gz"
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${bowtie2hkleid} ] ; then
				depend="-W depend=afterok:${bowtie2hkleid}"
			else
				depend=""
			fi
			qsub ${depend} -N ${jobbase}.${q} -l nodes=1:ppn=4 -l vmem=4gb \
				-j oe -o ${outbase}.${date}.out.txt \
				~/.local/bin/samtools_sequence_alignment_counts.bash \
					-F "view -q ${q} -o ${f} ${base}.bowtie2-e2e.SVAs_and_HERVs_KWHE.bam"
		fi
	done

done	#	for r1 in ${BASEDIR}/???.fastq.gz ; do
