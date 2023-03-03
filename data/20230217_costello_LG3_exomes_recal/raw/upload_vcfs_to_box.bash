#!/usr/bin/env bash


BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
BOX="${BOX_BASE}/${PROJECT}"

for f in vcfs/*snps.vcf{,.idx} ; do
	echo $f
	curl  --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

