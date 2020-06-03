#!/usr/bin/env bash

for subject in /raid/data/raw/USC-CHLA-NBL/20181003/*.R1.fastq.gz ; do
	root=${subject%%.R1.fastq.gz}
	base=$( basename $root )
	echo $subject $root
	if [[ -e ${base}.log ]] ; then
		echo "Log exists. Skipping."
	else
		dark.bash --threads 39 $root
	fi
done

