#!/usr/bin/env bash

for f in /francislab/data1/working/20191008_Stanford71/20200211-rerun/trimmed/length/unpaired/*q.gz ; do
echo $f
zcat ${f} | paste - - - - | cut -f 2 | awk '{print length($0)}' | gzip > $f.lengths.txt.gz
done
chmod -w /francislab/data1/working/20191008_Stanford71/20200211-rerun/trimmed/length/unpaired/*q.gz.lengths.txt.gz

