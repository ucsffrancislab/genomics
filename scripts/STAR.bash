#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

#	Search for the output file
while [ $# -gt 0 ] ; do
	case $1 in
		--outFileNamePrefix)
			shift; outprefix=$1; shift;;
		--outSAMtype)
			shift; outtype=$1; shift;;
		*)
			shift;;
	esac
done

f="${outprefix}Aligned.out.${outtype,,}"
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
			elif [ ${c} == '>' ] ; then
				mv ${outprefix}Unmapped.out.${m} ${outprefix}Unmapped.out.${r}.fasta
				gzip ${outprefix}Unmapped.out.${r}.fasta
				chmod a-w ${outprefix}Unmapped.out.${r}.fasta.gz
			fi
		fi
	done
fi

