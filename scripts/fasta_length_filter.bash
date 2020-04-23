#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

length=30

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		-i)
			shift; input=$1; shift;;
		-l)
			shift; length=$1; shift;;
		-o)
			shift; output=$1; shift;;
#		*)
#			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;	#	really should just be a single fasta file, maybe gzipped
	esac
done


f=${output}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	if [ "${input: -3}" == ".gz" ] ; then
		command="zcat ${input} "
	else
		command="cat ${input} "
	fi
	if [ "${input: -4}" == "q.gz" ] ; then
		command="${command} | paste - - - - "
	else
		command="${command} | paste - - "
	fi
	command="${command} | awk -F'\t' -v l=${length} '( length(\$2) < l )' | tr '\t' '\n' "
	if [ ${output: -3} == '.gz' ] ; then
		command="${command} | gzip"
	fi

	eval $command > ${f}

	chmod a-w $f
fi

