#!/usr/bin/env bash


BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
BOX="${BOX_BASE}/${PROJECT}"

for dir in bams/* ; do
	BOX="${BOX_BASE}/${PROJECT}/${dir}"
	for f in ${dir}/*{bam,bai} ; do
		echo $f
		curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
	done
done

