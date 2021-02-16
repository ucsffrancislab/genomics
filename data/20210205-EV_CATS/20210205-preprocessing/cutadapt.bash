#!/usr/bin/env bash

ARGS=$*

while [ $# -gt 0 ] ; do
	case $1 in
		-o)
			shift; output=$1; shift;;
	esac
done

cutadapt $ARGS
chmod -w ${output}

