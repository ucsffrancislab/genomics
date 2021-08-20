#!/usr/bin/env bash

set -x

#SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-k|--kmers)
			shift; kmers=$1; shift;;
		-i|--infile)
			shift; infile=$1; shift;;
		-o|--outbase)
			shift; outbase=$1; shift;;
#		*)
#			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

o=${outbase}.kmers.all.fastq.gz
if [ -f $o ] && [ ! -w $o ] ; then
	echo "Write-protected $o exists. Skipping."
else
	zcat ${infile} | paste - - - - | grep -f ${kmers} | tr "\t" "\n" | gzip > ${o}
	chmod -w ${o}
fi

all=${o}

#	kmer counts
for kmer in $( cat ${kmers} ) ; do
	o=${outbase}.${kmer}.txt
	if [ -f $o ] && [ ! -w $o ] ; then
		echo "Write-protected $o exists. Skipping."
	else
		${PWD}/kmer_count.bash -m ${kmer} -i ${all} -o ${o}
	fi
done

