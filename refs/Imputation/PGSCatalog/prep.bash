#!/usr/bin/env bash



for f in PGS*_hmPOS_GRCh37.txt.gz ; do
	echo $f
	header=$( zgrep -m 1 -n "hm_chr" $f | cut -d: -f1 )
	chr=$( zgrep -m1 -n hm_chr ${f} | cut -d: -f2 | tr "\t" "\n" | grep -n "hm_chr" | cut -d: -f1 )
	pos=$( zgrep -m1 -n hm_chr ${f} | cut -d: -f2 | tr "\t" "\n" | grep -n "hm_pos" | cut -d: -f1 )
	zcat $f | head -n ${header} > ${f%.txt.gz}.sorted.txt
	zcat $f | tail -n +$[header+1] | awk -F"\t" -v chr=${chr} '( $chr != "X" )' | sort -t $'\t' -k${chr}n,${chr} -k${pos}n,${pos} >> ${f%.txt.gz}.sorted.txt
	zcat $f | tail -n +$[header+1] | awk -F"\t" -v chr=${chr} '( $chr == "X" )' | sort -t $'\t' -k${chr}n,${chr} -k${pos}n,${pos} >> ${f%.txt.gz}.sorted.txt
	gzip ${f%.txt.gz}.sorted.txt

	chmod -w ${f%.txt.gz}.sorted.txt.gz

	ln -s ${f%.txt.gz}.sorted.txt.gz ${f%_hmPOS_GRCh37.txt.gz}.txt.gz

done

