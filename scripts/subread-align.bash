#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*


#SELECT_ARGS=""
#
##	Search for the output file
#while [ $# -gt 0 ] ; do
#	case $1 in
#		-o)
#			shift; output=$1; shift;;
#		*)
#			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
#	esac
#done


#	Search for the output file
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
	#	http://bioinf.wehi.edu.au/subread/
	#	-t (type 0 for rna, 1 for dna)
	#	-a /raid/refs/mirbase-hsa.gff3
	#subread-align $SELECT_ARGS | samtools view -F 4 -o ${output} -
	subread-align $ARGS
	chmod a-w $f
fi

