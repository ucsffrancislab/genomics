#!/usr/bin/env bash

for f in *.nonhg38.*.txt.gz ; do
#	base=${f%%.nonhg38.fasta.gz}
	base=${f%%.txt.gz}
	echo $f
	zcat $f | grep "^>" | sort | uniq -c | sort -rn > $base.viral_hits.txt
	chmod a-w $base.viral_hits.txt
done
