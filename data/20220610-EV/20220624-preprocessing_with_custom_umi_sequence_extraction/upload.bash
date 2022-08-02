#!/usr/bin/env bash

BOX_BASE="https://dav.box.com/dav/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )

BOX="${BOX_BASE}/${DATA}"
curl -netrc -X MKCOL "${BOX}/"
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
curl -netrc -X MKCOL "${BOX}/"

#curl -netrc -T metadata.csv "${BOX}/"
#BOX="${BOX_BASE}/${DATA}/${PROJECT}/rollup"
#curl -netrc -X MKCOL "${BOX}/"
#
#BOX="${BOX_BASE}/${DATA}/${PROJECT}/rollup"
#for f in rollup/rollup.merged/* ; do
#echo $f
#curl -netrc -T ${f} "${BOX}/"
#done

BOX="${BOX_BASE}/${DATA}/${PROJECT}/out"
curl -netrc -X MKCOL "${BOX}/"
for s in SFHH011AC SFHH011BB SFHH011BZ SFHH011CH SFHH011I SFHH011S ; do
	echo $s
	curl -netrc -T out/${s}.quality.umi.t1.t3.hg38.rx.marked.bam "${BOX}/"
	curl -netrc -T out/${s}.quality.umi.t1.t3.hg38.rx.marked.bai "${BOX}/"
	curl -netrc -T out/${s}.quality.umi.t1.t3.hg38.rx.marked.reference.fasta.gz "${BOX}/"
done

