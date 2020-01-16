#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

while [ $# -gt 0 ] ; do
	case $1 in
		-f|--featureCounts)
			shift; outbase=${1}; output=${1}.deseq.plots.pdf; shift;;
		*)
			shift;;
	esac
done

f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	deseq.R $ARGS
	chmod a-w ${outbase}.deseq.diffexpr-results.csv
	chmod a-w $f
fi

