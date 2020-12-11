#!/usr/bin/env bash

#	zcat /francislab/data1/raw/20201127-EV_CATS/output/trimmed*q.gz | paste - - - - | cut -f 2 | awk '{l=length;sum+=l;sumsq+=(l)^2;print "Avg:",sum/NR,"\tStddev:\t"sqrt((sumsq-sum^2/NR)/NR)}' > trimmed.avg_length.ssstdev.txt

#	tail -n 1 trimmed.avg_length.ssstdev.txt
#	Avg: 38.5553 	Stddev:	34.2855

OUT=${PWD}/kallisto

mkdir -p ${OUT}

for f in ${PWD}/output/trimmed*q.gz ; do
	base=${f%_001.fastq.gz}
	base=${base/_S?_L001/}
	base=${base/trimmed_/}
	basename=$(basename $base)
	echo $f
	echo $basename

	~/.local/bin/kallisto.bash quant -b 160 --threads 16 --single-overhang --single -l 38.5553 -s 34.2855 --index /francislab/data1/refs/kallisto/hrna_21.idx --output-dir ${OUT}/${basename} ${f}

done





#	Sleuth ....


