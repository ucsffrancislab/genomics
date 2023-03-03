#!/usr/bin/env bash


BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
BOX="${BOX_BASE}/${PROJECT}"

for dir in bams60/{Patient5[23456789],Patient[6789],Q,S}* ; do
	BOX="${BOX_BASE}/${PROJECT}/${dir}"
	for f in ${dir}/*{bam,bai} ; do
		echo $f
		curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
	done
done

