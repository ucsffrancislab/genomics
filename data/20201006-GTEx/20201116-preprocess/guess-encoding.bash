#/usr/bin/env bash

for f in trimmed/*R?.fastq.gz; do
	echo $f
	encoding=$( zcat $f | awk 'NR % 4 == 0' | guess-encoding.py -n 100000 2> /dev/null )
	echo ${f},${encoding} >> encoding.csv
done

