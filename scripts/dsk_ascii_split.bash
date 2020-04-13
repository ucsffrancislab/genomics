#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

mem=8000
threads=8
k=21
u=15

while [ $# -gt 0 ] ; do
	case $1 in
#		-infile)
#			shift; infile=$1; shift;;
		-k)
			shift; k=$1; shift;;
		-u|-uniq_mer_length)
			shift; u=$1; shift;;
#		-threads)
#			shift; threads=$1; shift;;
#		-mem)
#			shift; mem=$1; shift;;
		-outbase)
			shift; outbase=$1; shift;;
		*)
			shift;;
	esac
done


f="${outbase}.split"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

#	dsk.bash -nb-cores ${threads} -kmer-size ${k} -abundance-min 0 \
#		-max-memory ${mem} -file ${infile} -out ${outbase}.h5
#
#	dsk2ascii.bash -nb-cores ${threads} -file ${outbase}.h5 -out ${outbase}.txt.gz

	if [ ${k} -gt ${u} ] ; then

		zcat ${outbase}.txt.gz | awk -v l=$[k-u] -v outbase=${outbase} \
			'{print $0 > outbase"-"substr($1,0,l)".txt" }' 
			#'{print $0 | "gzip > "outbase"-"substr($1,0,l)".txt.gz" }' 
		gzip ${outbase}-*.txt

	fi

	touch ${outbase}.split
	chmod a-w ${outbase}.split
fi

