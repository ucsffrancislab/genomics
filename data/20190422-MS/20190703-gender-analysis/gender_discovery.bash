#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

for r1 in /raid/data/raw/MS-20190422/SF*_R1.fastq.gz ; do
	echo $r1
	r2=${r1/_R1./_R2.}
	echo $r2
	core=$( basename $r1 _R1.fastq.gz )

	f=${core}.XY.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bowtie2 --threads 40 --no-unal -x hg38.XY --very-sensitive -1 ${r1} -2 ${r2} -S ${core}.XY.sam
		samtools sort -o ${core}.XY.bam ${core}.XY.sam
		rm ${core}.XY.sam
		chmod a-w $f
	fi

	f=${core}.XY.bam.bai
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		samtools index ${core}.XY.bam
		chmod a-w $f
	fi

	f=${core}.X.count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		samtools view -f 2 -c ${core}.XY.bam chrX > ${f}
		chmod a-w $f
	fi

	f=${core}.Y.count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		samtools view -f 2 -c ${core}.XY.bam chrY > ${f}
		chmod a-w $f
	fi

	f=${core}.XY.ratio.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		X=$( cat ${core}.X.count.txt )
		Y=$( cat ${core}.Y.count.txt )
		echo "${X} / ${Y}" | bc -l > ${f}
		chmod a-w $f
	fi

done

