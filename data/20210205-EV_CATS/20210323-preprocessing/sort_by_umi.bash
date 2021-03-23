#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
set -x	#	print expanded command before executing it

while [ $# -gt 0 ] ; do
	case $1 in
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

zcat $input | paste - - - - | sort -k3,3 -k1,1 | tr "\t" "\n" | gzip > $output

chmod -w ${output}

