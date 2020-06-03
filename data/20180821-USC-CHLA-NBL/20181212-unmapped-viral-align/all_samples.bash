#!/usr/bin/env bash


#for virus in NC_001710.1 NC_001716.2 NC_001664.4 NC_000898.1 NC_08168.1 ; do
#for virus in NC_001710.1 NC_001716.2 NC_001664.4 NC_000898.1 ; do
#for virus in NC_001664.4 NC_000898.1 NC_008168.1 ; do

for virus in NC_008168.1 ; do
	echo Align to $virus
	bowtie2 --threads 35 --xeq -x virii/${virus} --very-sensitive -1 $( ls /raid/data/raw/USC-CHLA-NBL/2018????/*.R1.fastq.gz | paste -sd ',' ) -2 $( ls /raid/data/raw/USC-CHLA-NBL/2018????/*.R2.fastq.gz | paste -sd ',' ) 2>> ${virus}.log | samtools view -F 4 -o ${virus}.unsorted.bam -
	#chmod a-w ${virus}.unsorted.bam
	echo Sort
	samtools sort -o ${virus}.bam ${virus}.unsorted.bam
	chmod a-w ${virus}.bam
	echo Index
	samtools index ${virus}.bam
	chmod a-w ${virus}.bam.bai
	echo Depth
#	Should have
#	samtools depth -d 0 ${virus}.bam > ${virus}.depth.csv
	samtools depth ${virus}.bam > ${virus}.depth.csv
	chmod a-w ${virus}.depth.csv
done

