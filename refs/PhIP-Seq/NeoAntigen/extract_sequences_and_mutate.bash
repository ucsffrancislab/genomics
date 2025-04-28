#!/usr/bin/env bash


while read gene hotspot url ; do
#	basename $url
#	echo ${gene} ${hotspot}
	mut_from=${hotspot:0:1}
	mut_to=${hotspot: -1}
	pos=${hotspot#?}
	pos=${pos%?}
#	echo $pos
	sequence=$( tail -n +2 genes_for_hotspots/$( basename $url ) | tr -d '\n' )
#	existing=${sequence:$[pos-1]:1}

	echo ">${gene}:$[pos-5]-$[pos+5]:Original"
	echo ${sequence:$[pos-6]:11}
	echo ">${gene}:$[pos-5]-$[pos+5]:Mutation:${hotspot}"
	echo ${sequence:$[pos-6]:5}${mut_to}${sequence:$[pos]:5}


done < <( sed 's/,/ /g' genes_and_hotspots.csv | tail -n +2 )

