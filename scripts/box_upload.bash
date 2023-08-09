#!/usr/bin/env bash

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
#PROJECT=$( basename ${PWD} )
#DATA=$( basename $( dirname ${PWD} ) )
#BOX="${BOX_BASE}/${DATA}/${PROJECT}"

#dir=${PWD}
dir=$( dirname $( realpath --no-symlinks ${1} ) )
dir=${dir#/francislab/data1/raw/}
dir=${dir#/francislab/data1/working/}
BOX="${BOX_BASE}/${dir}"

echo $BOX

while [ $# -gt 0 ] ; do
	echo $1
	curl  --silent --ftp-create-dirs -netrc -T ${1} "${BOX}/"
	shift
done

