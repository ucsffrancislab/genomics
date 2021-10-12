#!/usr/bin/env bash

#NEED TO QUOTE THESE FILENAMES as many include []'s and such.


#for l in complete.?.*.genomic.fna.sequences.txt ; do
for l in complete.3???.*.genomic.fna.sequences.txt ; do
	echo ${l}
	b=$( basename $l .fna.sequences.txt )

	a=$( find split/${b}/ -type f | wc -l )
	c=$( cat ${l%.txt}.wc-l.txt )

	if [ ${a} -eq ${c} ] ; then
		echo "Equal"
	else
		echo "Problem : ${a} does not equal ${c}"
	fi

#	mkdir -p split2/${b}
#	for f in $( cat ${l} ) ; do
##		if [ ! -s "split/${f}.fa" ] ; then
##			echo "Missing or empty : $f" >> ${l}.missings.txt
##		else
#			mv "split/${f}.fa" split2/${b}/
##		fi
#	done
done



