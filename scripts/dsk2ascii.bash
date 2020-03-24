#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

#	Search for the output file
while [ $# -gt 0 ] ; do
	case $1 in
		-out)
			shift; output=$1; shift;;
		*)
			shift;;
	esac
done

f="${output}"
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	dsk2ascii $ARGS
	if [ ${f:(-3)} == '.gz' ] ; then
		mv ${f} ${f%.gz}
		gzip --best ${f%.gz}
	fi
	chmod a-w $f
fi

