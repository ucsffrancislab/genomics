#!/usr/bin/env bash


#--no-group-separator gets rid of the -- between matches, but is undocumented (not in my man page)
#Could grep parse out in following awk statement

#DIR="/francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/trimmed/length"

#	playing in scratch
DIR="/francislab/data1/working/20200407_Schizophrenia/20200617-post_metago/tmp"

mkdir out

for r1 in ${DIR}/????_R1.fastq.gz ; do
	echo "Processing ${r1}"

	r2=${r1/_R1/_R2}

	paste <( zcat ${r1} ) <( zcat ${r2} ) \
		| grep -f ASS_filtered_down_kmers.txt -B 1 -A 2 --no-group-separator \
		| awk -F"\t" \
			-v lr1=out/$( basename ${r1} .gz ) \
			-v lr2=out/$( basename ${r2} .gz ) \
			'{print $1 > lr1; print $2 > lr2}'
done






