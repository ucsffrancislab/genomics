#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x

ARGS=$*

#	Search for the output file
while [ $# -gt 0 ] ; do
	case $1 in
		-db)
			shift; db=$( basename $1 ); shift;;
		-query)
			shift; query=$1; shift;;
		*)
			shift;;
	esac
done

f=${query/.fasta/.blastn.${db}.txt.gz}
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"
	blastn $ARGS | gzip --best > ${f}
	chmod a-w $f
fi

