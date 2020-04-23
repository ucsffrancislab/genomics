#!/usr/bin/env bash

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

#ARGS=$*

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
	cmd="samtools $SELECT_ARGS | awk '{print \$3}' | sort | uniq -c"
	if [ ${output: -3} == '.gz' ] ; then
		cmd="${cmd} | gzip --best"
	fi
	cmd="${cmd} > ${f}"
	eval "${cmd}"
	chmod a-w $f
fi

