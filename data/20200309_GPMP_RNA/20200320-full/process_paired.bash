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


#for r1 in ${BASEDIR}/*E_R1.fastq.gz ; do
for r1 in ${BASEDIR}/SF12149*E_R1.fastq.gz ; do
#for r1 in ${BASEDIR}/SF12[234]*E_R1.fastq.gz ; do

	r2=${r1/_R1/_R2}

	#	NEED FULL PATH HERE ON THE CLUSTER
	base=${r1%_R1.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )
	jobbase=${jobbase%%_*}	#	SF12430-NE_S8_L001 -> SF12430-NE


	for ref in hg38  ; do

		outbase="${base}.STAR.${ref}"
		starid=""
		f=${outbase}.Aligned.out.bam
		starbam=${f}
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
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
					--outSAMunmapped Within KeepPairs \
					--readFilesIn ${r1} ${r2}" )
			#	I think that KeepPairs could have been dropped
			#		--outSAMunmapped Within KeepPairs
			#	Paired reads. To preserve lane and simplify merging, keep in sam.
			#		--outReadsUnmapped Fastx \
			echo "${starid}"
		fi

#		outbase="${base}.STAR.${ref}.unmapped"
#		unmappedid=""
#		f=${outbase}.fasta.gz
#		if [ -f $f ] && [ ! -w $f ] ; then
#			echo "Write-protected $f exists. Skipping."
#		else
#			if [ ! -z ${starid} ] ; then
#				depend="-W depend=afterok:${starid}"
#			else
#				depend=""
#			fi  
#			unmappedid=$( qsub ${depend} -N ${jobbase}.${ref}.un \
#				-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#				-oe -o ${outbase}.${date}.out.txt \
#				~/.local/bin/samtools.bash -F \
#					"fasta -f 4 --threads $[threads-1] -N -o ${f} ${starbam}" )
#			echo "${unmappedid}"
#		fi  

		infile="${base}.STAR.${ref}.unmapped.fasta.gz"

    # Count so can normalize
    #   
    # count_fasta_reads.bash *unmapped.fasta.gz
    #   
		unmapped_read_count=''
    f="${base}.STAR.${ref}.unmapped.fasta.gz.read_count.txt"
    if [ -f $f ] && [ ! -w $f ] ; then
      unmapped_read_count=$( cat ${f} )
      echo "Unmapped Count :${unmapped_read_count}:"
    fi  



		for dref in nr viral ; do
		#for dref in viral ; do

			diamondid=""
			outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}"
			f="${outbase}.csv.gz"
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				if [ ! -z ${unmappedid} ] ; then
					depend="-W depend=afterok:${unmappedid}"
				else
					depend=""
				fi
				case $dref in 
					nr) vmem=32;;
					viral) vmem=16;;
					*) vmem=8;;
				esac
				diamondid=$( qsub ${depend} -N ${jobbase}.${dref} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
					-j oe -o ${outbase}.out.txt \
					~/.local/bin/diamond.bash \
						-F "blastx --threads ${threads} --db ${DIAMOND}/${dref} \
							--query ${infile} --outfmt 6 --out ${f}" )
				echo $diamondid
			fi
			input=${f}



			summaryid=""
			outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}"
			#f1="${outbase}.summary.sum-species.normalized.txt.gz"
			#f2="${outbase}.summary.sum-genus.normalized.txt.gz"
			f1="${outbase}.summary.sum-species.txt.gz"
			f2="${outbase}.summary.sum-genus.txt.gz"
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

				qsub ${depend} -N ${jobbase}.s.${dref} \
					-j oe -o ${outbase}.${date}.out.txt \
					~/.local/bin/blastn_summarize_and_normalize_scratch.bash -F "\
						--input ${base}.STAR.${ref}.unmapped.diamond.${dref}.csv.gz \
						--levels species,genus \
						--unmapped_read_count '${unmapped_read_count}'"
					#~/.local/bin/blastn_summarize_and_normalize_scratch.bash -F "\
					#	--input ${base}.STAR.${ref}.unmapped.diamond.${dref}.csv.gz"
			fi





#	produces
#			outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}.summary"
#			f=${outbase}.txt.gz
#				outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}.summary.normalized"
#				f=${outbase}.txt.gz
#			for level in species genus ; do
#				outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}.summary.sum-${suffix}"
#				f=${outbase}.txt.gz
#					outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}.summary.sum-${suffix}.normalized"
#					f=${outbase}.txt.gz




#			summaryid=""
#			outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}.summary"
#			f=${outbase}.txt.gz
#			if [ -f $f ] && [ ! -w $f ] ; then
#				echo "Write-protected $f exists. Skipping."
#			else
#				if [ ! -z ${diamondid} ] ; then
#					depend="-W depend=afterok:${diamondid}"
#				else
#					depend=""
#				fi
##				if [ -f $input ] ; then
##					#	On first run, this wouldn't work
##					size=$( stat -c %s $input )
##					if [ $size -gt 10000000 ] ; then
##						echo "Size $size gt 10000000"
##						vmem=8
##					elif [ $size -gt 8000000 ] ; then
##						echo "Size $size gt 8000000"
##						vmem=6
##					else
##						echo "Size $size NOT gt 8000000"
##						vmem=4
##					fi
##				else
##					vmem=4
##				fi
#				vmem=8
#				#summaryid=$( qsub ${depend} -N ${jobbase}.s.${dref} -l nodes=1:ppn=2 -l vmem=${vmem}gb \
#				summaryid=$( qsub ${depend} -N ${jobbase}.s.${dref} -l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#					-j oe -o ${outbase}.${date}.out.txt \
#					~/.local/bin/blastn_summary.bash -F "-input ${input}" )
#				echo $summaryid
#			fi
#
#			summary=$f
#
#			#			normalize
#
#			if [ -n "${unmapped_read_count}" ] ; then
#				echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."
#				outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}.summary.normalized"
#				f=${outbase}.txt.gz
#				if [ -f $f ] && [ ! -w $f ] ; then
#					echo "Write-protected $f exists. Skipping."
#				else
#					if [ ! -z ${summaryid} ] ; then
#						depend="-W depend=afterok:${summaryid}"
#					else
#						depend=""
#					fi
#					#threads=8
#					vmem=8	#	4
#					qsub ${depend} -N ${jobbase}.norm.${dref} \
#						-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
#						-j oe -o ${outbase}.${date}.out.txt \
#						~/.local/bin/normalize_summary.bash -F "-input ${summary} -d ${unmapped_read_count}"
#				fi
#			fi
#
#			#			sum summaries
#
#			#for level in species genus ; do
#			for level in species ; do
#				suffix=${level%%,*}	#	in case a list of level's provided
#
#				sumsummaryid=""
#				outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}.summary.sum-${suffix}"
#				f=${outbase}.txt.gz
#				if [ -f $f ] && [ ! -w $f ] ; then
#					echo "Write-protected $f exists. Skipping."
#				else
#					if [ ! -z ${summaryid} ] ; then
#						depend="-W depend=afterok:${summaryid}"
#					else
#						depend=""
#					fi
#					sumsummaryid=$( qsub ${depend} -N ${jobbase}.${suffix:0:2}.${dref} -l nodes=1:ppn=8 -l vmem=8gb \
#						-j oe -o ${outbase}.${date}.out.txt \
#						~/.local/bin/sum_summary.bash -F "-input ${summary} -level ${level}" )
#					echo $sumsummaryid
#				fi
#				sumsummary=${f}
#	
#				#			normalize
#
#				if [ -n "${unmapped_read_count}" ] ; then
#					echo "Unmapped Read Count ${unmapped_read_count} exists. Normalizing."
#					outbase="${base}.STAR.${ref}.unmapped.diamond.${dref}.summary.sum-${suffix}.normalized"
#					f=${outbase}.txt.gz
#					if [ -f $f ] && [ ! -w $f ] ; then
#						echo "Write-protected $f exists. Skipping."
#					else
#						if [ ! -z ${sumsummaryid} ] ; then
#							depend="-W depend=afterok:${sumsummaryid}"
#						else
#							depend=""
#						fi
#						#-l nodes=1:ppn=2 -l vmem=4gb \
#						qsub ${depend} -N ${jobbase}.${suffix:0:2}.norm \
#							-l nodes=1:ppn=8 -l vmem=8gb \
#							-j oe -o ${outbase}.${date}.out.txt \
#							~/.local/bin/normalize_summary.bash \
#								-F "-input ${sumsummary} -d ${unmapped_read_count}"
#					fi
#				fi
#
#			done	#	for level in species genus subfamily ; do
	
		done	#	for dref in nr viral ; do







#		for bref in viral.masked ; do


#		done	#	for bref in viral.masked ; do

	done	#	for ref in hg38  ; do

done	#	for r1 in /francislab/data1/working/20200303_GPMP/20200306-full/trimmed/length/*_R1.fastq.gz ; do

