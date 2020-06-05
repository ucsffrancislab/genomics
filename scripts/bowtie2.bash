#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*


#	No easily computable output file so pick custom argument, pass on the rest

sortbam=false
threads=0
SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		#-o)
		#	new versions of bowtie2 take the -b option which will return a bam file
		-b)
			SELECT_ARGS="${SELECT_ARGS} $1";
			shift; output=$1;
			SELECT_ARGS="${SELECT_ARGS} $1";
			shift;;
		--sort)
			shift; sortbam=true;;
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
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	#	The latest version of bowtie2 will write bam output if given the -b options
	bowtie2 $SELECT_ARGS 2> ${f}.err.txt
	#bowtie2 $SELECT_ARGS 2> ${f}.err.txt | samtools view -o ${f} -
	#bowtie2 $SELECT_ARGS | samtools view -o ${f} -
	if $sortbam; then
		mv ${f} ${f/%.bam/.unsorted.bam}
		samtools sort --threads ${threads} -o ${f} ${f/%.bam/.unsorted.bam}
		\rm ${f/%.bam/.unsorted.bam}
	fi
	chmod a-w $f
fi

