#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
set -x	#	print expanded command before executing it

#ARGS=$*

while [ $# -gt 0 ] ; do
	case $1 in
		-l)
			shift; length=$1; shift;;
		-i)
			shift; input=$1; shift;;
		-o)
			shift; output=$1; shift;;
		*)
			shift;
	esac
done

#python3 ${PWD}/bin/fumi_tools copy_umi $ARGS

#	Assuming input and output are fastq.gz

zcat $input | paste - - - - | awk -v l=${length} -F"\t" '{split($1,a,":"); print $1" "substr($2,0,l)"_"a[length(a)]; print $2; print $3; print $4}' | gzip > $output
chmod -w ${output}

