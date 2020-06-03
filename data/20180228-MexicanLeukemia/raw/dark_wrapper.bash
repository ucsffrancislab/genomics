#!/usr/bin/env bash


for subject in $( ls *_L001_R1_001.fastq.gz ) ; do

	echo $subject
	base=${subject%%1_R1_001.fastq.gz}

	dark.bash $base

done
