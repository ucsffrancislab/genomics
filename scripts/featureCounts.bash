#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

while [ $# -gt 0 ] ; do
	case $1 in
		-o)
			shift; output=$1; shift;;
		*)
			shift;;
	esac
done

f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	featureCounts $ARGS
	#	-F GFF -t miRNA -g Name -a /data/shared/francislab/refs/fasta/hg38.chr.hsa.gff3 -o testingfc 77.h38au.bowtie2.e2e.bam
	chmod a-w $f
fi

