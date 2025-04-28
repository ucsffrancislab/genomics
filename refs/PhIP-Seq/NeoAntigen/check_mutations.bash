#!/usr/bin/env bash


while read gene hotspot url ; do
	basename $url
	echo $hotspot
	mut_from=${hotspot:0:1}
	mut_to=${hotspot: -1}
	pos=${hotspot#?}
	pos=${pos%?}
	echo $pos
	sequence=$( tail -n +2 genes_for_hotspots/$( basename $url ) | tr -d '\n' )
	existing=${sequence:$[pos-1]:1}
	if [ ${existing} == ${mut_from} ] ; then
		echo "Matched"
	else
		echo "Not matched"
		echo ${existing} ${mut_from}
	fi
done < <( sed 's/,/ /g' genes_and_hotspots.csv | tail -n +2 )

