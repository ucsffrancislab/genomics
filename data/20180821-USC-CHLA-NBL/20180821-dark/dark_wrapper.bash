#!/usr/bin/env bash

for subject in /raid/data/raw/USC/*.R1.fastq.gz ; do
	base=${subject%%.R1.fastq.gz}
	echo $subject $base
	if [[ ! -e ${base}.log ]] ; then
		dark.bash --threads 20 $base
	fi
done

