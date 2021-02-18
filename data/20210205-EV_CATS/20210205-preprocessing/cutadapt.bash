#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
set -x	#	print expanded command before executing it

ARGS=$*

while [ $# -gt 0 ] ; do
	case $1 in
		-o)
			shift; output=$1; shift;;
	esac
done

cutadapt $ARGS
chmod -w ${output}

