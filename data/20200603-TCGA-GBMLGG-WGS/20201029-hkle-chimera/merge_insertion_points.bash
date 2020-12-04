#!/usr/bin/env bash



mkdir merged

for c in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY ; do

	echo $c

	./merge_insertion_points.py -c $c -o merged/merged.0-D.rounded.csv.gz -p 'premerge/*ts' > merged/merge.${c}.out 2> merged/merge.${c}.err

done

