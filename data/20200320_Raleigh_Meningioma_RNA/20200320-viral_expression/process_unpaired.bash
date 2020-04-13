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


for r1 in ${BASEDIR}/???.fastq.gz ; do
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
				diamondid=$( qsub ${depend} -N ${jobbase}.${dref} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-j oe -o ${outbase}.out.txt \
					~/.local/bin/diamond.bash \
						-F "blastx --threads 8 --db ${DIAMOND}/${dref} \
							--query ${infile} --outfmt 6 --out ${f}" )
				echo $diamondid
			fi
			input=${f}

			summaryid=""
			outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${dref}.summary"
			f=${outbase}.txt.gz
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${diamondid} ] ; then
					depend="-W depend=afterok:${diamondid}"
				else
					depend=""
				fi
#				if [ -f $input ] ; then
#					#	On first run, this wouldn't work
#					size=$( stat -c %s $input )
#					if [ $size -gt 10000000 ] ; then
#						echo "Size $size gt 10000000"
#						vmem=8
#					elif [ $size -gt 8000000 ] ; then
#						echo "Size $size gt 8000000"
#						vmem=6
#					else
#						echo "Size $size NOT gt 8000000"
#						vmem=4
#					fi
#				else
#					vmem=4
#				fi
				#summaryid=$( qsub ${depend} -N ${jobbase}.s.${dref} -l nodes=1:ppn=2 -l vmem=${vmem}gb \
				#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				summaryid=$( qsub ${depend} -N ${jobbase}.s.${dref} \
					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/blastn_summary.bash -F "-input ${input}" )
				echo $summaryid
			fi

			summary=$f

			#			normalize

			if [ -n "${unmapped_read_count}" ] ; then
				echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."
				outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${dref}.summary.normalized"
				f=${outbase}.txt.gz
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ! -z ${summaryid} ] ; then
						depend="-W depend=afterok:${summaryid}"
					else
						depend=""
					fi
					#-l nodes=1:ppn=2 -l vmem=4gb \
					#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
					qsub ${depend} -N ${jobbase}.norm.${dref} \
						-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
						-j oe -o ${outbase}.${date}.out.txt \
						~/.local/bin/normalize_summary.bash -F "-input ${summary} -d ${unmapped_read_count}"
				fi
			fi

			#			sum summaries

			for level in species genus subfamily ; do
				suffix=${level%%,*}	#	in case a list of level's provided

				sumsummaryid=""
				outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${dref}.summary.sum-${suffix}"
				f=${outbase}.txt.gz
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ! -z ${summaryid} ] ; then
						depend="-W depend=afterok:${summaryid}"
					else
						depend=""
					fi
					#	-l nodes=1:ppn=2 -l vmem=4gb \
					#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
					sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2}.${dref} \
						-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
						-j oe -o ${outbase}.${date}.out.txt \
						~/.local/bin/sum_summary.bash -F "-input ${summary} -level ${level}" )
					echo $sumsummaryid
				fi
				sumsummary=${f}

				#			normalize

				if [ -n "${unmapped_read_count}" ] ; then
					echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."
	
					outbase="${base}.STAR.${ref}.Unmapped.out.diamond.${dref}.summary.sum-${suffix}.normalized"
					f=${outbase}.txt.gz
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${sumsummaryid} ] ; then
							depend="-W depend=afterok:${sumsummaryid}"
						else
							depend=""
						fi
						#-l nodes=1:ppn=2 -l vmem=4gb \
						#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
						qsub ${depend} -N ${jobbase}.${suffix:0:2}.norm \
							-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
							-j oe -o ${outbase}.${date}.out.txt \
							~/.local/bin/normalize_summary.bash \
								-F "-input ${sumsummary} -d ${unmapped_read_count}"
					fi
				fi

			done	#	for level in species genus subfamily ; do
	
		done	#	for d in nr viral viral ; do


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
					-j oe -o ${outbase}.out.txt \
					~/.local/bin/blastn.bash \
						-F "-num_threads ${threads} -db ${BLASTDB}/${bref} \
							-query ${infile} -outfmt 6 -out ${f}" )
				echo $blastnid
			fi
			input=${f}

			summaryid=""
			outbase="${base}.STAR.${ref}.Unmapped.out.blastn.${bref}.summary"
			f=${outbase}.txt.gz
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${blastnid} ] ; then
					depend="-W depend=afterok:${blastnid}"
				else
					depend=""
				fi
#				if [ -f $input ] ; then
#					#	On first run, this wouldn't work
#					size=$( stat -c %s $input )
#					if [ $size -gt 10000000 ] ; then
#						echo "Size $size gt 10000000"
#						vmem=8
#					elif [ $size -gt 8000000 ] ; then
#						echo "Size $size gt 8000000"
#						vmem=6
#					else
#						echo "Size $size NOT gt 8000000"
#						vmem=4
#					fi
#				else
#					vmem=4
#				fi
				#	-l nodes=1:ppn=2 -l vmem=${vmem}gb \
				#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
				summaryid=$( qsub ${depend} -N ${jobbase}.s.${bref} \
					-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/blastn_summary.bash -F "-input ${input}" )
				echo $summaryid
			fi

			summary=$f

			#			normalize

			if [ -n "${unmapped_read_count}" ] ; then
				echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."
				outbase="${base}.STAR.${ref}.Unmapped.out.blastn.${bref}.summary.normalized"
				f=${outbase}.txt.gz
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ! -z ${summaryid} ] ; then
						depend="-W depend=afterok:${summaryid}"
					else
						depend=""
					fi
					#-l nodes=1:ppn=2 -l vmem=4gb \
					#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
					qsub ${depend} -N ${jobbase}.norm.${bref} \
						-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
						-j oe -o ${outbase}.${date}.out.txt \
						~/.local/bin/normalize_summary.bash -F "-input ${summary} -d ${unmapped_read_count}"
				fi
			fi

#	viral is species so no need to sum to species
#
#			#			sum summaries
#
#			#for level in species genus subfamily ; do
			for level in species genus ; do
				suffix=${level%%,*}	#	in case a list of level's provided

				sumsummaryid=""
				outbase="${base}.STAR.${ref}.Unmapped.out.blastn.${bref}.summary.sum-${suffix}"
				f=${outbase}.txt.gz
				if [ -f $f ] && [ ! -w $f ] ; then
					echo "Write-protected $f exists. Skipping."
				else
					if [ ! -z ${summaryid} ] ; then
						depend="-W depend=afterok:${summaryid}"
					else
						depend=""
					fi
					#	-l nodes=1:ppn=2 -l vmem=4gb \
					#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
					sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2}.${bref} \
						-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
						-j oe -o ${outbase}.${date}.out.txt \
						~/.local/bin/sum_summary.bash -F "-input ${summary} -level ${level}" )




					echo $sumsummaryid
				fi
				sumsummary=${f}

				#			normalize

				if [ -n "${unmapped_read_count}" ] ; then
					echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."
	
					outbase="${base}.STAR.${ref}.Unmapped.out.blastn.${bref}.summary.sum-${suffix}.normalized"
					f=${outbase}.txt.gz
					if [ -f $f ] && [ ! -w $f ] ; then
						echo "Write-protected $f exists. Skipping."
					else
						if [ ! -z ${sumsummaryid} ] ; then
							depend="-W depend=afterok:${sumsummaryid}"
						else
							depend=""
						fi
						#-l nodes=1:ppn=2 -l vmem=4gb \
						#	-o ${outbase}.${date}.out.txt -e ${outbase}.${date}.err.txt \
						qsub ${depend} -N ${jobbase}.${suffix:0:2}.norm \
							-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
							-j oe -o ${outbase}.${date}.out.txt \
							~/.local/bin/normalize_summary.bash \
								-F "-input ${sumsummary} -d ${unmapped_read_count}"
					fi
				fi

			done	#	for level in species genus subfamily ; do

		done	#	for bref in viral.masked ; do

	done	#	for ref in hg38  ; do

done	#	for r1 in /francislab/data1/working/20200303_GPMP/20200306-full/trimmed/length/*_R1.fastq.gz ; do
