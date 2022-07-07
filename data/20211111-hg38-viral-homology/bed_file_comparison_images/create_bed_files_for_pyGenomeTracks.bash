#!/usr/bin/env bash


for f in /francislab/data1/working/20211111-hg38-viral-homology/out/*/*fasta ; do
	echo $f
	b=$( basename $f )
	d=$( dirname $f )
	d=$( basename $d )
	mkdir -p $d
	accession=$( basename ${f} | awk -F. '{print $1"."$2}' )
	echo $accession
	chars=$( tail -n +2 ${f} | tr -d "\n" | wc --chars )
	tail -n +2 ${f} | tr -d "\n" | sed 's/\(.\)/\1\n/g' | awk -v a=${accession} -v c=${chars} 'BEGIN{true=1;false=0;n=false;start=0}
		(  /N/ && !n ){n=true; start=NR-1}
		( !/N/ &&  n && start ){n=false;blockSizes=blockSizes""NR-start",";blockStarts=blockStarts""start",";blockCount++}
		END{ print a"\t1\t"c"\t.\t0\t+\t0\t0\t0\t"blockCount+2"\t0,"blockSizes"0,\t0,"blockStarts""c-1"," }' > ${d}/${b}.bed
done

