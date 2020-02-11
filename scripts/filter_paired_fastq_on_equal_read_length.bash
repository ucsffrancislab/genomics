#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

#while [ $# -gt 0 ] ; do
#	case $1 in
#		-o)
#			shift; output=$1; shift;;
#		*)
#			shift;;
#	esac
#done

f=${3}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	filter_paired_fastq_on_equal_read_length.py $ARGS
	chmod a-w $3 $4 $5 $6
fi

