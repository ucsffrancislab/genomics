#!/usr/bin/env bash

f=$1

echo $f

for chr in {1..22} X ; do

	mkdir -p ${chr}

	out=${chr}/${f%_hmPOS_GRCh37.txt.gz}.txt

	if [ -f ${out}.gz ] ; then
	
		echo "${out}.gz exists"
	
	else
	
		header=$( zgrep -m 1 -n "hm_chr" $f | cut -d: -f1 )
		chr_col=$( zgrep -m1 -n hm_chr ${f} | cut -d: -f2 | tr "\t" "\n" | grep -n "hm_chr" | cut -d: -f1 )
		pos_col=$( zgrep -m1 -n hm_chr ${f} | cut -d: -f2 | tr "\t" "\n" | grep -n "hm_pos" | cut -d: -f1 )

		zcat $f | head -n ${header} > ${out}

		zcat $f | tail -n +$[header+1] | awk -F"\t" -v chr=${chr} -v chr_col=${chr_col} '( $chr_col == chr )' | sort -t $'\t' -k${pos_col}n,${pos_col} | uniq >> ${out}

		gzip ${out}
	
		chmod -w ${out}.gz
	
	fi

done

