#!/usr/bin/env bash

for f in *.nonhg38.fasta.gz ; do
#	base=${f%%.nonhg38.fasta.gz}
	base=${f%%.gz}
	echo $f
	zcat $f | grep -c "^>" > $base.reads.txt
	chmod a-w $base.reads.txt
done
