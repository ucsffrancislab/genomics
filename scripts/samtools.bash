#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

#	#	Search for the output file
#	while [ $# -gt 0 ] ; do
#		case $1 in
#			-o)
#				shift; output=$1; shift;;
#			*)
#				shift;;
#		esac
#	done

#	No easily computable output file so pick custom argument, pass on the rest

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-o)
			shift; output=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	samtools $SELECT_ARGS > ${f}
	chmod a-w $f
fi

