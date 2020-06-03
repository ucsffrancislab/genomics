#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail



for r1 in /raid/data/raw/MS-20190422/*R1.fastq.gz ; do
	r2=${r1/_R1/_R2}
	base=$(basename $r1 _R1.fastq.gz) 

	ref="hg38.chr6_alts"

	f=${base}.${ref}.bam
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		bowtie2 --threads 40 --very-sensitive -x ${ref} -1 ${r1} -2 ${r2} \
			2> ${base}.bowtie2.err \
			| samtools view -o ${base}.${ref}.bam - > ${base}.samtools.log 2> ${base}.samtools.err
		chmod a-w $f
	fi

	f=${base}.${ref}.counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		samtools view ${base}.${ref}.bam | awk '{print $3}' | sort | uniq -c > $f
		chmod a-w $f
	fi

	f=${base}.${ref}.proper_pair.counts
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		samtools view -f 2 ${base}.${ref}.bam | awk '{print $3}' | sort | uniq -c > $f
		chmod a-w $f
	fi

done 

