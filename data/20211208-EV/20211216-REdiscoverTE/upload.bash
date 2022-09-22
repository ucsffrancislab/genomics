#!/usr/bin/env bash

#BOX_BASE="https://dav.box.com/dav/Francis _Lab_Share"
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )

BOX="${BOX_BASE}/${DATA}"
#curl -netrc -X MKCOL "${BOX}/"
#curl -netrc --ftp-create-dirs "${BOX}/"
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
#curl -netrc -X MKCOL "${BOX}/"
#curl -netrc --ftp-create-dirs "${BOX}/"

for f in HAvL.csv REdiscoverTE_EdgeR_rmarkdown.bash REdiscoverTE_EdgeR_rmarkdown.Rmd ; do
	echo $f
	curl --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done


BOX="${BOX_BASE}/${DATA}/${PROJECT}/rmarkdown_results"
for f in rmarkdown_results/* ; do
	echo $f
	curl --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done


