#!/usr/bin/env bash

set -x

BASE=/data/shared/francislab/data/raw/SFGF-Shaw-GS-13361/trimmed/unpaired

zcat ${BASE}/*fastq.gz | paste - - - - | cut -f 2 | \
	awk '{ l=length; sum+=l; sumsq+=(l)^2 }END{print "Avg:",sum/NR,"\tStddev:\t"sqrt((sumsq-sum^2/NR)/NR)}' \
	> ${BASE}/avg_length.ssstdev.txt

