#!/usr/bin/env bash

module load bedtools2/2.29.2

for ini in /francislab/data1/working/20211111-hg38-viral-homology/bed_file_comparison_images/*/*ini ; do
	b=$( basename ${ini} .ini )
	echo ${b}
	d=$( dirname ${ini} )
	fasta=/francislab/data1/working/20211111-hg38-viral-homology/out/raw/${b}.fasta
	chars=$( tail -n +2 ${fasta} | tr -d "\n" | wc --chars )
	title=$( head -1 ${fasta} | sed -e 's/^>//' | cut -c1-60)
	if [ -e ${ini%.ini}.png ] ; then
		echo "${ini%.ini}.png exists. Skipping."
	else
		pyGenomeTracks --tracks ${ini} \
			--region ${b}:0-${chars} \
			--trackLabelFraction 0.15 \
			--width 30 \
			--dpi 120 \
			--title "${title}                " \
			--fontSize 16 \
			-o ${ini%.ini}.png 
	fi
done


