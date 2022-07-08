#!/usr/bin/env bash

BOX_BASE="https://dav.box.com/dav/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )

#BOX="${BOX_BASE}/${DATA}"
#curl -netrc -X MKCOL "${BOX}/"
#BOX="${BOX_BASE}/${DATA}/${PROJECT}"
#curl -netrc -X MKCOL "${BOX}/"
#curl -netrc -T metadata.csv "${BOX}/"
#BOX="${BOX_BASE}/${DATA}/${PROJECT}/rollup"
#curl -netrc -X MKCOL "${BOX}/"
#
#BOX="${BOX_BASE}/${DATA}/${PROJECT}/rollup"
#for f in rollup/rollup.merged/* ; do
#echo $f
#curl -netrc -T ${f} "${BOX}/"
#done

for d in results_* ; do
echo $d
BOX="${BOX_BASE}/${DATA}/${PROJECT}/${d}"
curl -netrc -X MKCOL "${BOX}/"
for f in ${d}/* ; do
echo $f
curl -netrc -T ${f} "${BOX}/"
done
done

