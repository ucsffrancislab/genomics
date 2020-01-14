#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x


while [ $# -gt 0 ] ; do
	case $1 in
		-i|--i*)
			shift; file=$1; shift;;
		-t|--t*)
			shift; threads=$1; shift ;;
		*)
			shift;;
	esac
done


unique_extension=".fastq.gz"

INDIR=$( dirname $file )
OUTPREFIX=$( basename $file	${unique_extension} )
OUTDIR="${INDIR}/${OUTPREFIX}_kmers"


f1=${OUTDIR}_sorted.txt.gz
if [ -f $f1 ] && [ ! -w $f1 ] ; then
	echo "Write-protected $f1 exists. Skipping."
else

	f2=${OUTDIR}_sorted.txt
	if [ -f $f2 ] && [ ! -w $f2 ] ; then
		echo "Write-protected $f2 exists. Skipping."
	else
		#	Original version does this with CUTOFF. I have no idea why.
		#	Set it to 1, output it to a file, then add 1 and use as the lower limit.
		#	Everytime? Why not just fixed as 2?
		#	CUTOFF=1
		#	echo $CUTOFF > ${OUTPREFIX}_cutoff.csv
		#	${jellyfishDir}/jellyfish dump -c -L `expr $CUTOFF + 1` \
		#		${OUTPREFIX}_kmers_jellyfish > ${OUTPREFIX}_kmers.txt

		f3=${OUTDIR}.txt
		if [ -f $f3 ] && [ ! -w $f3 ] ; then
			echo "Write-protected $f3 exists. Skipping."
		else
			echo "Creating $f3"
			hawk_jellyfish dump --column --lower-count 2 ${OUTDIR}_jellyfish > ${f3}
			chmod a-w $f3
		fi

		echo "Creating $f2"
		#sort --parallel=${threads} -n -k 1 ${f3} > ${f2}
		sort --parallel=${threads} --numeric-sort --key 1 ${f3} > ${f2}
		#sort -n -k 1 ${f3} > ${f2}
		chmod a-w $f2

		rm -f $f3
	fi

	gzip --best $f2
	#	should be "a-w" already as gzip preserves
	#	it also removes the source so no rm necessary
fi

