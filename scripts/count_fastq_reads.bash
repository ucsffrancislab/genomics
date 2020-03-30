#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

while [ $# -gt 0 ] ; do

	echo $1

	f=${1}.read_count.txt
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		echo "Creating $f"
		if [ "${1: -3}" == ".gz" ] ; then
			command="zcat "
		else
			command="cat "
		fi
		command="${command} ${1} | paste - - - - | wc -l"
		eval $command > ${f}
		chmod a-w $f
	fi

	shift

done

