#!/usr/bin/env bash

mkdir -p genes_for_hotspots

cd genes_for_hotspots

while read gene hotspot url ; do
	file=$( basename $url )
	if [ -f ${file} ] ; then
		echo "${file} exists. Skipping"
	else
		echo "Downloading ${file}"
		wget ${url}
	fi
done < <( sed 's/,/ /g' ../genes_and_hotspots.csv | tail -n +2 )

cd ..

