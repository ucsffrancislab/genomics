#!/usr/bin/env bash

f=$1


if [ -f ${f%_hmPOS_GRCh38.txt.gz}.txt.gz ] ; then

	echo "${f%_hmPOS_GRCh38.txt.gz}.txt.gz exists"

else

	echo $f
	header=$( zgrep -m 1 -n "hm_chr" $f | cut -d: -f1 )
	chr=$( zgrep -m1 -n hm_chr ${f} | cut -d: -f2 | tr "\t" "\n" | grep -n "hm_chr" | cut -d: -f1 )
	pos=$( zgrep -m1 -n hm_chr ${f} | cut -d: -f2 | tr "\t" "\n" | grep -n "hm_pos" | cut -d: -f1 )
	zcat $f | head -n ${header} > ${f%.txt.gz}.sorted.txt
	zcat $f | tail -n +$[header+1] | awk -F"\t" -v chr=${chr} '( $chr ~ /[0-9]/ )' | sort -t $'\t' -k${chr}n,${chr} -k${pos}n,${pos} | uniq >> ${f%.txt.gz}.sorted.txt
	zcat $f | tail -n +$[header+1] | awk -F"\t" -v chr=${chr} '( $chr == "X" )' | sort -t $'\t' -k${chr}n,${chr} -k${pos}n,${pos} | uniq >> ${f%.txt.gz}.sorted.txt
	gzip ${f%.txt.gz}.sorted.txt

	chmod -w ${f%.txt.gz}.sorted.txt.gz

	if [ $( zgrep -vsc "^#" ${f%.txt.gz}.sorted.txt.gz ) -gt 1 ] ; then

		ln -s ${f%.txt.gz}.sorted.txt.gz ${f%_hmPOS_GRCh38.txt.gz}.txt.gz

	fi

fi


