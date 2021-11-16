#!/usr/bin/env bash

mkdir for_reference

for genome in $( cat /francislab/data1/refs/refseq/viral-20210916/viral_sequences.txt ) ; do

#	echo $genome
	accession=$( basename $genome | awk 'BEGIN{FS=OFS="_"}{print $1,$2}' )
#	echo $accession

	mm="out/split.vsl/${accession}.masked.split.25.mask.fasta"
	m1="out/split.vsl/${accession}.split.25.mask.fasta"
	m2="out/masks/${accession}.masked.fasta"
	raw="out/raw/${accession}.fasta"
	if [ -f "${mm}" ] ; then
		ln -s "../${mm}" for_reference/${accession}.fasta
	elif [ -f "${m1}" ] ; then
		ln -s "../${m1}" for_reference/${accession}.fasta
	elif [ -f "${m2}" ] ; then
		#	Should never really happen
		echo "${accesion} masked raw should never happen"
	elif [ -f "${raw}" ] ; then
		ln -s "../${raw}" for_reference/${accession}.fasta
	else
		echo "${accession} fastas not found"
	fi

done


exit


-r--r----- 1 gwendt francislab  25347 Nov 12 15:15 out/masks/NC_001664.4.fasta.cat
-r--r----- 1 gwendt francislab   4088 Nov 12 15:15 out/masks/NC_001664.4.fasta.out
-r--r----- 1 gwendt francislab   1857 Nov 12 15:15 out/masks/NC_001664.4.fasta.tbl
-r--r----- 1 gwendt francislab 162658 Nov 12 15:15 out/masks/NC_001664.4.masked.fasta
-r--r----- 1 gwendt francislab     50 Nov 12 15:15 out/masks/NC_001664.4.masked.fasta.base_count.txt
-r--r----- 1 gwendt francislab 162658 Nov 12 15:14 out/raw/NC_001664.4.fasta
-r--r----- 1 gwendt francislab     40 Nov 12 15:15 out/raw/NC_001664.4.fasta.base_count.txt
-r--r----- 1 gwendt francislab 387106 Nov 12 15:15 out/split/NC_001664.4.masked.split.25.fa
-r--r----- 1 gwendt francislab 395228 Nov 12 15:15 out/split/NC_001664.4.split.25.fa
-r--r----- 1 gwendt francislab     74 Nov 12 15:15 out/split.vsl/NC_001664.4.masked.split.25.mask.bed
-r--r----- 1 gwendt francislab 162658 Nov 12 15:15 out/split.vsl/NC_001664.4.masked.split.25.mask.fasta
-r--r----- 1 gwendt francislab     50 Nov 12 15:15 out/split.vsl/NC_001664.4.masked.split.25.mask.fasta.base_count.txt
-r--r----- 1 gwendt francislab      4 Nov 12 15:15 out/split.vsl/NC_001664.4.masked.split.25.mask.masked_length.txt
-r--r----- 1 gwendt francislab  24415 Nov 12 15:15 out/split.vsl/NC_001664.4.masked.split.25.sam
-r--r----- 1 gwendt francislab    195 Nov 12 15:15 out/split.vsl/NC_001664.4.masked.split.25.summary.txt
-r--r----- 1 gwendt francislab    311 Nov 12 15:15 out/split.vsl/NC_001664.4.split.25.mask.bed
-r--r----- 1 gwendt francislab 162658 Nov 12 15:15 out/split.vsl/NC_001664.4.split.25.mask.fasta
-r--r----- 1 gwendt francislab     50 Nov 12 15:15 out/split.vsl/NC_001664.4.split.25.mask.fasta.base_count.txt
-r--r----- 1 gwendt francislab      5 Nov 12 15:15 out/split.vsl/NC_001664.4.split.25.mask.masked_length.txt
-r--r----- 1 gwendt francislab  37522 Nov 12 15:15 out/split.vsl/NC_001664.4.split.25.sam
-r--r----- 1 gwendt francislab    197 Nov 12 15:15 out/split.vsl/NC_001664.4.split.25.summary.txt
