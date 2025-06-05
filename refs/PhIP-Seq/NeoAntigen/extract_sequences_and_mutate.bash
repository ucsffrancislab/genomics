#!/usr/bin/env bash

#	Fundamental immune–oncogenicity trade-offs define driver mutation fitness
#	41586_2022_4696_MOESM1_ESM supplementary information

#	Manually generated the csv from within the paper

while read gene hotspot url ; do
#	basename $url
#	echo ${gene} ${hotspot}
	mut_from=${hotspot:0:1}
	mut_to=${hotspot: -1}
	pos=${hotspot#?}
	pos=${pos%?}
#	echo $pos
	sequence=$( tail -n +2 genes_for_hotspots/$( basename $url ) | tr -d '\n' )
	existing=${sequence:$[pos-1]:1}

	# THESE ALL MATCH THE EXPECTED

	if [ ${existing} == ${mut_from} ] ; then

		#echo ">HotSpot_${gene}:$[pos-5]-$[pos+5]:Original"
		#echo ${sequence:$[pos-6]:11}
		#echo ">HotSpot_${gene}:$[pos-5]-$[pos+5]:Mutation:${hotspot}"
		#echo ${sequence:$[pos-6]:5}${mut_to}${sequence:$[pos]:5}

		echo ">HotSpot_${gene}:$[pos-4]-$[pos+4]:Original"
		echo ${sequence:$[pos-5]:9}
		echo ">HotSpot_${gene}:$[pos-4]-$[pos+4]:Mutation:${hotspot}"
		echo ${sequence:$[pos-5]:4}${mut_to}${sequence:$[pos]:4}

	else

		echo "${gene} ${hotspot} ${url}"
		echo "${existing} != ${mut_from}"
		exit

	fi

done < <( sed 's/,/ /g' 41586_2022_4696_MOESM1_ESM.csv | tail -n +2 )

