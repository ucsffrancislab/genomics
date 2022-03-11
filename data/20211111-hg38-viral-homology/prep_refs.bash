#!/usr/bin/env bash

mkdir Raw
mkdir RM
mkdir RawHM
mkdir RMHM

for genome in $( cat /francislab/data1/refs/refseq/viral-20210916/viral_sequences.txt ) ; do

#	echo $genome
	accession=$( basename $genome | awk 'BEGIN{FS=OFS="_"}{print $1,$2}' )
#	echo $accession

	RMHM="out/RM.split.HM.bt2/${accession}.masked.split.25.mask.fasta"
	RawHM="out/raw.split.HM.bt2/${accession}.split.25.mask.fasta"
	RM="out/RM/${accession}.masked.fasta"
	Raw="out/raw/${accession}.fasta"

	if [ -f "${Raw}" ] ; then
		ln -s "../${Raw}" Raw/${accession}.fasta
	else
		echo "${accession} fastas not found"
	fi

	if [ -f "${RM}" ] ; then
		ln -s "../${RM}" RM/${accession}.fasta
	elif [ -f "${Raw}" ] ; then
		ln -s "../${Raw}" RM/${accession}.fasta
	else
		echo "${accession} fastas not found"
	fi

	if [ -f "${RawHM}" ] ; then
		ln -s "../${RawHM}" RawHM/${accession}.fasta
	elif [ -f "${RM}" ] ; then
		#	Should never really happen
		#echo "${accesion} masked raw should never happen"
		ln -s "../${RM}" RawHM/${accession}.fasta
	elif [ -f "${Raw}" ] ; then
		ln -s "../${Raw}" RawHM/${accession}.fasta
	else
		echo "${accession} fastas not found"
	fi

	if [ -f "${RMHM}" ] ; then
		ln -s "../${RMHM}" RMHM/${accession}.fasta
	elif [ -f "${RawHM}" ] ; then
		ln -s "../${RawHM}" RMHM/${accession}.fasta
	elif [ -f "${RM}" ] ; then
		#	Should never really happen
		echo "${accesion} masked raw should never happen"
	elif [ -f "${Raw}" ] ; then
		ln -s "../${Raw}" RMHM/${accession}.fasta
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
