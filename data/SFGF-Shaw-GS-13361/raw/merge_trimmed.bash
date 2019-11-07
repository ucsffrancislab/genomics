#!/usr/bin/env bash

set -x

if [ $# -eq 0 ] ; then
	script=$( readlink -f $0 )
	for i in $( seq -w 1 77 ) ; do
		qsub -N ${i}.merge_trimmed $script -F ${i}
	done
else
	#	Merge / unpair data
	BASE=/data/shared/francislab/data/raw/SFGF-Shaw-GS-13361/trimmed
	zcat ${BASE}/${1}_*.fastq.gz | sed -E 's/ ([[:digit:]]):.*$/\/\1/' | gzip > ${BASE}/unpaired/${1}.fastq.gz
fi


