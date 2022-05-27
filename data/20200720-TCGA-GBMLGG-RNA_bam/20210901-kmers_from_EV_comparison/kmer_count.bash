#!/usr/bin/env bash

set -x

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-m|--mer|-k|--kmer)
			shift; mer=$1; shift;;
		-i|--infile)
			shift; infile=$1; shift;;
		-o|--output)
			shift; output=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

c=$( zcat ${infile} | paste - - - - | cut -f2 | grep ${mer} | wc -l )

echo ${c} > ${output}

chmod -w ${output}

