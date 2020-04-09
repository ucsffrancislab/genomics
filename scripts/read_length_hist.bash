#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

input=$1

f=${input}.length_hist.csv.gz
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	if [ ${input: -4} == "q.gz" ] ; then
		zcat ${input} \
			| paste - - - - \
			| cut -f 2 \
			| awk '{print length($0)}' \
			| sort \
			| uniq -c \
			| gzip > ${f}
	elif [ ${input: -4} == "a.gz" ] ; then
		zcat ${input} \
			| paste - - \
			| cut -f 2 \
			| awk '{print length($0)}' \
			| sort \
			| uniq -c \
			| gzip > ${f}
	elif [ ${input: -1} == "q" ] ; then
		cat ${input} \
			| paste - - - - \
			| cut -f 2 \
			| awk '{print length($0)}' \
			| sort \
			| uniq -c \
			| gzip > ${f}
	elif [ ${input: -1} == "a" ] ; then
		cat ${input} \
			| paste - - \
			| cut -f 2 \
			| awk '{print length($0)}' \
			| sort \
			| uniq -c \
			| gzip > ${f}
	fi

	chmod a-w $f
fi

