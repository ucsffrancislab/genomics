#!/usr/bin/env bash

set -x

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-m|--min)
			shift; min=$1; shift;;
		-o|--output)
			shift; output=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done


c=$( zcat ${SELECT_ARGS} | paste - - - - | cut -f2 | grep -x ".\{${min},\}" | wc -l )

echo ${c} > ${output}

chmod -w ${output}

