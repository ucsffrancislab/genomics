#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module'

hostname
date

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

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

	zcat ${SELECT_ARGS} | sed -E 's/ ([[:digit:]]):.*$/\/\1/' | gzip > ${f}

	chmod a-w $f
fi

