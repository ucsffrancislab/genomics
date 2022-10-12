#!/usr/bin/env bash

BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )

for d in rmarkdown_results* ; do
	echo $d
	BOX="${BOX_BASE}/${DATA}/${PROJECT}/${d}"
	for f in ${d}/* ; do
		echo $f
		curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
	done
done

