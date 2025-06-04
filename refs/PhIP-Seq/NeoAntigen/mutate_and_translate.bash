#!/usr/bin/env bash

sequence=$( tail -n +2 $1 | tr -d '\n' )
#echo ${sequence:0:10}

echo $2

#	5G>T

#	mut_from=${2:0:1}
#	#echo ${mut_from}
#	mut_to=${2: -1}
#	#echo "${mut_to}"
#	pos=${2#?}
#	pos=${pos%?}
#	#echo $pos

mut_to=${2: -1}

x=${2:0: -2}
mut_from=${x: -1}
#echo ${mut_from}
#echo "${mut_to}"

pos=${2:0: -3}
#pos=${2#?}
#pos=${pos%?}
echo $pos
echo "${sequence:$[pos-3]:5}"

existing=${sequence:$[pos-1]:1}
#echo ${existing}

if [ ! ${mut_from} == ${existing} ] ; then
	echo "INCORRECT : ${mut_from} != ${sequence:$[pos-2]:3}"
fi

#echo ">seq\n${sequence}"



#	./mutate_and_translate.bash NM_005228.5.fna 3614C>T

