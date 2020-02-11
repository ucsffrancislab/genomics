#!/usr/bin/env bash

set -x

if [ $# -eq 0 ] ; then
	script=$( readlink -f $0 )
	for i in $( seq -w 1 77 ) ; do
		qsub -N ${i}.trim_reads -l vmem=32gb -o ${OUT}.bbduk.out -e ${OUT}.bbduk.err $script -F ${i}
	done
else

	BASE=/francislab/data1/working/20191008_Stanford71/20191218-everything
	OUT=${BASE}/trimmed/${1}

	/home/gwendt/.local/BBMap/bbduk.sh \
		-Xmx4g \
		in1=${BASE}/${1}_R1.fastq.gz \
		in2=${BASE}/${1}_R2.fastq.gz \
		out1=${OUT}_R1.fastq.gz \
		out2=${OUT}_R2.fastq.gz \
		outs=${OUT}_S.fastq.gz \
		ref=${BASE}/adapters.fa \
		ktrim=r \
		k=23 \
		mink=11 \
		hdist=1 \
		tbo \
		ordered=t \
		bhist=${OUT}.bhist.txt \
		qhist=${OUT}.qhist.txt \
		gchist=${OUT}.gchist.txt \
		aqhist=${OUT}.aqhist.txt \
		lhist=${OUT}.lhist.txt \
		gcbins=auto \
		maq=10

fi
