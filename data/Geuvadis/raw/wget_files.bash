#!/usr/bin/env bash


dir=/francislab/data1/raw/Geuvadis
mkdir -p ${dir}/bam

for f in $( cat ${dir}/bam_urls.txt ) ; do
	echo $f
	b=$( basename $f )
	o=${dir}/bam/${b}
	if [ -f ${o} ] && [ ! -w ${o} ] ; then
		echo "Write-protected $b exists. Skipping."
	else
		wget --no-check-certificate -O ${o} ${f}
		chmod -w ${o}
	fi
done

