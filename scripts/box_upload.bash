#!/usr/bin/env bash

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
#PROJECT=$( basename ${PWD} )
#DATA=$( basename $( dirname ${PWD} ) )
#BOX="${BOX_BASE}/${DATA}/${PROJECT}"

while [ $# -gt 0 ] ; do
	echo $1

	#dir=${PWD}
	dir=$( dirname $( realpath --no-symlinks ${1} ) )
#	dir=${dir#/francislab/data?/refs/}
	dir=${dir#/francislab/data?/raw/}
	dir=${dir#/francislab/data?/workin*/}
	dir=${dir#/francislab/data?/}
	BOX="${BOX_BASE}/${dir}"
	echo $BOX

	curl  --silent --ftp-create-dirs -netrc -T ${1} "${BOX}/"
	shift
done

