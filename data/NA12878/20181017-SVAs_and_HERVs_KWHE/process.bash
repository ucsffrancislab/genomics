#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

wd=$PWD


echo "Beginning $wd"

date

f=NA12878-SVAs_and_HERVs_KWHE.endtoend.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	bowtie2 --threads 40 --xeq --very-sensitive --all -x NA12878 -f \
		-U /raid/refs/fasta/SVAs_and_HERVs_KWHE.fasta \
		| samtools view -o $f -
	chmod a-w $f
fi

samtools view $f  | awk '{print $1}' | sort | uniq -c >> $f.txt

date

f=NA12878-SVAs_and_HERVs_KWHE.local.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	bowtie2 --threads 40 --xeq --very-sensitive-local --all -x NA12878 -f \
		-U /raid/refs/fasta/SVAs_and_HERVs_KWHE.fasta \
		| samtools view -o $f -
	chmod a-w $f
fi

samtools view $f  | awk '{print $1}' | sort | uniq -c >> $f.txt

date

f=hg38-SVAs_and_HERVs_KWHE.endtoend.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	bowtie2 --threads 40 --xeq --very-sensitive --all -x hg38 -f \
		-U /raid/refs/fasta/SVAs_and_HERVs_KWHE.fasta \
		| samtools view -o $f -
	chmod a-w $f
fi

samtools view $f  | awk '{print $1}' | sort | uniq -c >> $f.txt

date

f=hg38-SVAs_and_HERVs_KWHE.local.bam
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	bowtie2 --threads 40 --xeq --very-sensitive-local --all -x hg38 -f \
		-U /raid/refs/fasta/SVAs_and_HERVs_KWHE.fasta \
		| samtools view -o $f -
	chmod a-w $f
fi

samtools view $f  | awk '{print $1}' | sort | uniq -c >> $f.txt

date

echo "Done"

