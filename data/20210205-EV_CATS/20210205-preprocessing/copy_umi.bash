#!/usr/bin/env bash

ARGS=$*

while [ $# -gt 0 ] ; do
	case $1 in
		-o)
			shift; output=$1; shift;;
	esac
done

python3 ${PWD}/bin/fumi_tools copy_umi $*
chmod -w ${output}

