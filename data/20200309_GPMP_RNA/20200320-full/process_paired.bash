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

BASEDIR=/francislab/data1/working/20200309_GPMP_RNA/20200320-full/trimmed/length


for r1 in ${BASEDIR}/*E_R1.fastq.gz ; do

	r2=${r1/_R1/_R2}

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%_R1.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )
	jobbase=${jobbase%%_*}	#	SF12430-NE_S8_L001 -> SF12430-NE


	for ref in hg38  ; do

		outbase="${base}.STAR.${ref}"
		starid=""
		f=${outbase}.bam
		starbam=${f}
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			starid=$( qsub -N ${jobbase}.${ref} -l nodes=1:ppn=${threads} -l vmem=32gb \
				-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				~/.local/bin/STAR.bash \
				-F "--runMode alignReads \
					--outFileNamePrefix ${outbase}. \
					--outSAMtype BAM Unsorted \
					--genomeDir ${STAR}/${ref} \
					--runThreadN ${threads} \
					--outSAMattrRGline ID:${jobbase} SM:${jobbase} \
					--readFilesCommand zcat \
					--outSAMunmapped Within KeepPairs \
					--readFilesIn ${r1} ${r2}" )
			#	Paired reads. To preserve lane and simplify merging, keep in sam.
			#		--outReadsUnmapped Fastx \
			echo "${starid}"
		fi

		outbase="${base}.STAR.${ref}.unmapped"
		unmappedid=""
		f=${outbase}.fasta.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			if [ ! -z ${starid} ] ; then
				depend="-W depend=afterok:${starid}"
			else
				depend=""
			fi  
			unmappedid=$( qsub ${depend} -N ${jobbase}.${ref}.un \
				-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
				-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				~/.local/bin/samtools.bash -F \
					"fasta -f 4 --threads $[threads-1] -N -o ${f} ${starbam}" )
			echo "${unmappedid}"
		fi  

		infile="${base}.STAR.${ref}.unmapped.fasta.gz"

		for d in nr viral ; do

			diamondid=""
			outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${d}"
			f="${outbase}.csv.gz"
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${starid} ] ; then
					depend="-W depend=afterok:${starid}"
				else
					depend=""
				fi
				diamondid=$( qsub ${depend} -N ${jobbase}.${d} -l nodes=1:ppn=8 -l vmem=16gb \
					-o ${outbase}.diamond.${d}.out.txt \
					-e ${outbase}.diamond.${d}.err.txt \
					~/.local/bin/diamond.bash \
						-F "blastx --threads 8 --db ${DIAMOND}/${d} \
							--query ${infile} --outfmt 6 --out ${f}" )
				echo $diamondid
			fi
			input=${f}

			summaryid=""
			outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${d}.summary"
			f=${outbase}.txt.gz
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${diamondid} ] ; then
					depend="-W depend=afterok:${diamondid}"
				else
					depend=""
				fi
				if [ -f $input ] ; then
					#	On first run, this wouldn't work
					size=$( stat -c %s $input )
					if [ $size -gt 10000000 ] ; then
						echo "Size $size gt 10000000"
						vmem=8
					elif [ $size -gt 8000000 ] ; then
						echo "Size $size gt 8000000"
						vmem=6
					else
						echo "Size $size NOT gt 8000000"
						vmem=4
					fi
				else
					vmem=4
				fi
				summaryid=$( qsub ${depend} -N ${jobbase}.s.${d} -l nodes=1:ppn=2 -l vmem=${vmem}gb \
					-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
					~/.local/bin/blastn_summary.bash -F "-input ${input}" )
				echo $summaryid
			fi

			summary=$f

#			count_base=$( basename $input .diamond.viral.csv.gz )
#			unmapped_read_count=$( cat /francislab/data1/raw/1000genomes/unmapped/${count_base}.unmapped_read_count.txt )

#			

#			normalize
#
#
#			outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${d}.summary.normalized"
#			f=${outbase}.txt.gz
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				if [ ! -z ${summaryid} ] ; then
#					depend="-W depend=afterok:${summaryid}"
#				else
#					depend=""
#				fi
#				#-l nodes=1:ppn=2 -l vmem=4gb \
#				qsub ${depend} -N ${jobbase}.norm.${d} \
#					-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
#					~/.local/bin/normalize_summary.bash -F "-input ${summary} -d ${unmapped_read_count}"
#			fi
#
#





#			sum summaries

#			outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${d}.summary

			for level in species genus subfamily ; do
				suffix=${level%%,*}	#	in case a list of level's provided

				sumsummaryid=""
				outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${d}.summary.sum-${suffix}"
				f=${outbase}.txt.gz
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ! -z ${summaryid} ] ; then
						depend="-W depend=afterok:${summaryid}"
					else
						depend=""
					fi
					sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2}.${d} -l nodes=1:ppn=2 -l vmem=4gb \
						-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
						~/.local/bin/sum_summary.bash -F "-input ${summary} -level ${level}" )
					echo $sumsummaryid
				fi
				sumsummary=${f}
	


#			normalize
#
#
#				outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${d}.summary.sum-${suffix}.normalized"
#				f=${outbase}.txt.gz
#				if [ -f $f ] && [ ! -w $f ] ; then
#					echo "Write-protected $f exists. Skipping."
#				else
#					if [ ! -z ${sumsummaryid} ] ; then
#						depend="-W depend=afterok:${sumsummaryid}"
#					else
#						depend=""
#					fi
#					#-l nodes=1:ppn=2 -l vmem=4gb \
#					qsub ${depend} -N ${jobbase}.${suffix:0:2}.norm \
#						-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
#						~/.local/bin/normalize_summary.bash \
#							-F "-input ${sumsummary} -d ${unmapped_read_count}"
#				fi
#



			done	#	for level in species genus subfamily ; do
	
		done	#	for d in nr viral viral.masked ; do

	done	#	for ref in hg38  ; do

done	#	for r1 in /francislab/data1/working/20200303_GPMP/20200306-full/trimmed/length/*_R1.fastq.gz ; do

