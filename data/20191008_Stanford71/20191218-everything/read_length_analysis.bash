#!/usr/bin/env bash

set -x

if [ $# -eq 0 ] ; then
	script=$( readlink -f $0 )
	qsub $script -F ignored_option
else
	BASE=/francislab/data1/working/20191008_Stanford71/20191218-everything/trimmed/unpaired
	zcat ${BASE}/*fastq.gz | paste - - - - | cut -f 2 | \
		awk '{ l=length; sum+=l; sumsq+=(l)^2 }END{print "Avg:",sum/NR,"\tStddev:\t"sqrt((sumsq-sum^2/NR)/NR)}' \
		> ${BASE}/avg_length.ssstdev.txt
fi

