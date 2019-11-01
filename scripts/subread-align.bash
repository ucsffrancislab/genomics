#!/usr/bin/env bash

#	This script will be called

#	qsub .... subread-align.bash -F ...

#	qsub -l nodes=1:ppn=4 -l vmem=8gb subread-align.bash -F -t 0 -T 4 -i REF -r R1 -R R2 -o OUTPUT




set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

ARGS=$*


#output=qsub.subread-align.out

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
	subread-align $ARGS
	chmod a-w $f
fi

