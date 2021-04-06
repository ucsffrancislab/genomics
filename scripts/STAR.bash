#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
echo "Slurm job id:${SLURM_JOBID}:"
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	module load CBI star/2.7.7a samtools/1.10
fi
set -x	#	print expanded command before executing it

ARGS=$*

sorted=false

#	Search for the output file
while [ $# -gt 0 ] ; do
	case $1 in
		--outFileNamePrefix)
			shift; outprefix=$1; shift;;
		--outSAMtype)
			shift; outtype=$1; 
			if [ $2 == "SortedByCoordinate" ] ; then
				sorted=true
			fi
			shift;;
		--runThreadN)
			shift; threads=$1; shift;;
#--runThreadN 8
		*)
			shift;;
	esac
done

if $sorted; then
	f="${outprefix}Aligned.sortedByCoord.out.${outtype,,}"
else
	f="${outprefix}Aligned.out.${outtype,,}"
fi

if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	STAR $ARGS
	chmod a-w $f

	for m in mate1 mate2 ; do
		if [ -f ${outprefix}Unmapped.out.${m} ] ; then
			c=$( head -c 1 ${outprefix}Unmapped.out.${m} )
			r=${m/mate/R}
			if [ ${c} == '@' ] ; then
				mv ${outprefix}Unmapped.out.${m} ${outprefix}Unmapped.out.${r}.fastq
				gzip ${outprefix}Unmapped.out.${r}.fastq
				chmod a-w ${outprefix}Unmapped.out.${r}.fastq.gz

				count_fastq_reads.bash ${outprefix}Unmapped.out.${r}.fastq.gz
			elif [ ${c} == '>' ] ; then
				mv ${outprefix}Unmapped.out.${m} ${outprefix}Unmapped.out.${r}.fasta
				gzip ${outprefix}Unmapped.out.${r}.fasta
				chmod a-w ${outprefix}Unmapped.out.${r}.fasta.gz

				count_fasta_reads.bash ${outprefix}Unmapped.out.${r}.fasta.gz
			fi
		fi
	done

	#	01.bbduk1.unpaired.STAR.hg38.Aligned.sortedByCoord.out.bam
	#	01.bbduk1.unpaired.STAR.hg38.Aligned.toTranscriptome.out.bam

	tbam="${outprefix}Aligned.toTranscriptome.out.bam"
	if [ -f ${tbam} ] ; then
		#	-F = NOT
		#	0xf04	3844	UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY
		samtools view -c -F 3844 ${tbam} > ${tbam}.aligned_count.txt
		chmod a-w ${tbam}.aligned_count.txt

		#	-f = IS
		#	0x4	4	UNMAP
		samtools view -c -f 4    ${tbam} > ${tbam}.unaligned_count.txt
		chmod a-w ${tbam}.unaligned_count.txt
	fi

	#samtools.bash fasta -f 4 --threads $[${PBS_NUM_PPN:-1}-1] -N -o ${f%.bam}.unmapped.fasta.gz ${f}
	samtools.bash fasta -f 4 --threads $[${threads:-1}-1] -N -o ${f%.bam}.unmapped.fasta.gz ${f}
	chmod a-w ${f%.bam}.unmapped.fasta.gz

	#	Produces ${f%.bam}.unmapped.fasta.gz.read_count.txt
	count_fasta_reads.bash ${f%.bam}.unmapped.fasta.gz

	#	-F = NOT
	#	0xf04	3844	UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY
	samtools view -c -F 3844 $f > $f.aligned_count.txt
	chmod a-w $f.aligned_count.txt

	#	-f = IS
	#	0x4	4	UNMAP
	samtools view -c -f 4    $f > $f.unaligned_count.txt
	chmod a-w $f.unaligned_count.txt
fi

