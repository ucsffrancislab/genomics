#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

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

#	sort can use a lot of tmp disk space on a hige list
#	so counting the reads myself

	if [ ${input: -4} == "q.gz" ] || [ ${input: -4} == "fqgz" ]; then
		zcat ${input} \
			| paste - - - - \
			| cut -f 2 \
			| awk '{c[length($0)]++}END{for(n in c){print c[n],n}}' \
			| sort -k2n \
			| gzip > ${f}

#			| awk '{print length($0)}' \
#			| sort \
#			| uniq -c \
#			| sort -k2n \
#			| gzip > ${f}
	elif [ ${input: -4} == "a.gz" ] ; then
		zcat ${input} \
			| paste - - \
			| cut -f 2 \
			| awk '{c[length($0)]++}END{for(n in c){print c[n],n}}' \
			| sort -k2n \
			| gzip > ${f}

#			| awk '{print length($0)}' \
#			| sort \
#			| uniq -c \
#			| sort -k2n \
#			| gzip > ${f}
	elif [ ${input: -1} == "q" ] ; then
		cat ${input} \
			| paste - - - - \
			| cut -f 2 \
			| awk '{c[length($0)]++}END{for(n in c){print c[n],n}}' \
			| sort -k2n \
			| gzip > ${f}

#			| awk '{print length($0)}' \
#			| sort \
#			| uniq -c \
#			| sort -k2n \
#			| gzip > ${f}
	elif [ ${input: -1} == "a" ] ; then
		cat ${input} \
			| paste - - \
			| cut -f 2 \
			| awk '{c[length($0)]++}END{for(n in c){print c[n],n}}' \
			| sort -k2n \
			| gzip > ${f}

#			| awk '{print length($0)}' \
#			| sort \
#			| uniq -c \
#			| sort -k2n \
#			| gzip > ${f}
	fi

	chmod a-w $f
fi

