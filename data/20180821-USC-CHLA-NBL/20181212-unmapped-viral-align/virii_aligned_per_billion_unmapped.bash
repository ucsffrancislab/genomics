#!/usr/bin/env bash

#for r1 in /raid/data/raw/USC-CHLA-NBL/2018????/*.R1.fastq.gz ; do basename $r1 .R1.fastq.gz ; done > subjects.txt
#for virus in /raid/refs/fasta/virii/*fasta ; do basename $virus .fasta; done > virii_versions.txt
#head -1q /raid/refs/fasta/virii/*fasta | sed 's/^>//' > virii_details.txt

subjects=$( cat subjects.txt )

echo "virus/subject,"$subjects | tr " " ","

#for virus in $( cat virii_details.txt ) ; do
while read virus ; do
	echo -n \"${virus}\"

	version=${virus%% *}
	#echo $version

	for subject in $subjects ; do
		#file="${subject}.${version}.bowtie2.mapped.count.txt"
		#file="${subject}.${version}.bowtie2.mapped.ratio_total.txt"
		file="${subject}/${subject}.${version}.bowtie2.mapped.ratio_unmapped.txt"
		if [ -f $file ] ; then
			count=$( cat $file | awk '{print $1" * 1000000000"}' | bc )
			count=${count%.*}
		else
			count=""
		fi
		echo -n ,${count}
	done
	echo
done < virii_details.txt
