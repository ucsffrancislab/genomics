#!/usr/bin/env bash

for subject in /raid/data/raw/USC-CHLA-NBL/20181204/*.R1.fastq.gz ; do
	root=${subject%%.R1.fastq.gz}
	base=$( basename $root )
	echo $subject $root
	if [[ -e ${base}.log ]] ; then
		echo "Log exists. Skipping."
	else
		dark.bash --threads 40 $root
	fi
done

