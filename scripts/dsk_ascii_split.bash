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
		-k)
			shift; k=$1; shift;;
		-u|-uniq_mer_length)
			shift; u=$1; shift;;
		-outbase)
			shift; outbase=$1; shift;;
		*)
			shift;;
	esac
done


f="${outbase}" #	DIRECTORY!
if [ -d $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	mkdir -p "${outbase}"

	if [ ${k} -gt ${u} ] ; then

#		filebase="${outbase}/$( basename ${outbase} )"
#		zcat ${outbase}.txt.gz | awk -v l=$[k-u] -v filebase=${filebase} \
#			'{print $0 > filebase"-"substr($1,0,l)".txt" }' 
#			#'{print $0 | "gzip > "outbase"-"substr($1,0,l)".txt.gz" }' 
#		gzip ${filebase}-*.txt

		#	assuming k=31 and u=15
		#dsk_ascii_split.py ${outbase}.txt.gz
		
		dsk_ascii_split.py --prefix_length=$[k-u] ${outbase}.txt.gz

	fi

	chmod -R a-w ${outbase}/
fi

