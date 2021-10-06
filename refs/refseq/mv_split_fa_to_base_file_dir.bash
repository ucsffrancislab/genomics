#!/usr/bin/env bash

#NEED TO QUOTE THESE FILENAMES as many include []'s and such.

#for l in complete.*.*.genomic.fna.sequences.txt ; do echo ${l}; for f in $( cat ${l} ) ; do if [ ! -s "split/${f}.fa" ] ;then echo "Missing or empty : $f" >> ${l}.missings.txt ; fi ; done ; done


#complete.146.1.genomic.fna.sequences.txt

#for l in complete.14[6789].*.genomic.fna.sequences.txt complete.1[56789]?.*.genomic.fna.sequences.txt complete.[23456789]??.*.genomic.fna.sequences.txt ; do
#for l in complete.1???.*.genomic.fna.sequences.txt ; do
#for l in complete.2[23]??.*.genomic.fna.sequences.txt ; do
#for l in complete.2242.2.genomic.fna.sequences.txt complete.2264.1.genomic.fna.sequences.txt ; do
#for l in complete.2[45678]??.*.genomic.fna.sequences.txt ; do

#for l in complete.?.*.genomic.fna.sequences.txt ; do
#for l in complete.[3-9].*.genomic.fna.sequences.txt ; do
for l in complete.???.*.genomic.fna.sequences.txt ; do
	echo ${l}
	b=$( basename $l .fna.sequences.txt )
	mkdir -p split2/${b}
	for f in $( cat ${l} ) ; do
#		if [ ! -s "split/${f}.fa" ] ; then
#			echo "Missing or empty : $f" >> ${l}.missings.txt
#		else
			mv "split/${f}.fa" split2/${b}/
#		fi
	done
done



