#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

while [ $# -gt 0 ] ; do
	case $1 in
		-p|--path)
			shift; path=${1}; shift;;
		-s|--suffix)
			shift; suffix=${1}; shift;;
		*)
			shift;;
	esac
done

f=${path}/${suffix}.sleuth.plots.pdf
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	sleuth.R $ARGS
	#chmod a-w ${outbase}.deseq.diffexpr-results.csv
	chmod a-w $f
fi

