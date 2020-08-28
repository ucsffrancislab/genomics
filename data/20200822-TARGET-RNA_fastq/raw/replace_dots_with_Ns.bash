#!/usr/bin/env bash

mkdir fastq-nodots

for f in fastq/*fastq.gz ; do
	echo $f
	b=$( basename $f )
	zcat $f | sed -n '2~4s/\./N/g;p' | gzip > fastq-nodots/${b}
done


