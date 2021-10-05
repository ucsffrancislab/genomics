#!/usr/bin/env bash



#	for f in /francislab/data1/raw/20211001-EV/SFHH00*R2_001.fastq.gz ; do
#		basename $f
#		#a=$( zcat $f | sed -n '2~4p' | grep "^.........GTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT" | wc -l ) # complete
#		a=$( zcat $f | sed -n '2~4p' | grep "^.........GTTTTTTTTTTTTTTTTTTTTTTTTT" | wc -l )
#		#a=$( zcat $f | sed -n '2~4p' | grep "^.........GTTTTTTTTTTTTTTTTTTTT" | wc -l )
#		b=$( zcat $f | sed -n '2~4p' | wc -l )
#		c=$( echo "scale=2; 100 * ${a} / ${b}" | bc -l 2> /dev/null)
#		echo "${a} / ${b} = ${c}"
#	done



#for f in /francislab/data1/raw/20211001-EV/SFHH00*R2_001.fastq.gz ; do
for f in $PWD/out/SFHH00*R2.fastq.gz ; do
	basename $f
	#zcat $f | sed -n '2~4p' | grep "^.........GTTTTTTTTTTTTTTTTTTTTTTTTT" | cut -c1-9 | sort | uniq -c | sort -n -r | head
	zcat $f | sed -n '2~4p' | grep "^.........GTTT" | cut -c1-9 | sort | uniq -c | sort -n -r | head
done

