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
	module load CBI htslib samtools 
#bowtie2
fi
set -x	#	print expanded command before executing it

ARGS=$*

#	No easily computable output file so pick custom argument, pass on the rest

count=true
sortbam=false
threads=0
SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-o|--output)
			shift; output=$1; shift;;
		--sort)
			shift; sortbam=true;;
		--nocount)
			shift; count=false;;
		-@|--threads)
			SELECT_ARGS="${SELECT_ARGS} $1";
			shift; threads=$1;
			SELECT_ARGS="${SELECT_ARGS} $1";
			shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done


f=${output}
if [ -f ${f} ] && [ ! -w ${f} ] ; then
	echo "Write-protected ${f} exists. Skipping."
else
	echo "Creating ${f}"
	/c4/home/gwendt/github/benLangmead/bowtie2/bowtie2 $SELECT_ARGS 2> ${f}.err.txt | samtools view -o ${f} -
	#bowtie2 $SELECT_ARGS | samtools view -o ${f} -
	if $sortbam; then
		mv ${f} ${f/%.bam/.unsorted.bam}
		samtools sort --threads ${threads} -o ${f} ${f/%.bam/.unsorted.bam}
		\rm ${f/%.bam/.unsorted.bam}
		samtools index ${f}
		chmod a-w ${f}.bai
	fi
	chmod a-w ${f}

	if $count; then
		#	-F = NOT
		#	0xf04	3844	UNMAP,SECONDARY,QCFAIL,DUP,SUPPLEMENTARY
		samtools view -c -F 3844 ${f} > ${f}.aligned_count.txt
		chmod a-w ${f}.aligned_count.txt

		#	-f = IS
		#	0x4	4	UNMAP
		samtools view -c -f 4    ${f} > ${f}.unaligned_count.txt
		chmod a-w ${f}.unaligned_count.txt

		samtools view -F4 ${f} | awk '{print $3}' | gzip > ${f}.aligned_sequences.txt.gz
		chmod a-w ${f}.aligned_sequences.txt.gz

		zcat ${f}.aligned_sequences.txt.gz | sort --parallel=8 | uniq -c | sort -rn > ${f}.aligned_sequence_counts.txt
		chmod a-w ${f}.aligned_sequence_counts.txt
	fi

fi

echo "Done"
date

