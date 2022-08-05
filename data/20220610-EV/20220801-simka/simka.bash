#!/usr/bin/env bash

#for i in 1 2 3 4 5 6 7 8 ; do
#
#	echo ${i}
#
#	out=${PWD}/out${i}
#	mkdir -p ${out}
#
#	tmp=${PWD}/out${i}-tmp
#	mkdir -p ${tmp}
#
#	~/github/GATB/simka/build/bin/simka -in ${PWD}/datasets${i} -out ${out} -out-tmp ${tmp}
#
#done


#	i=5
#	s="-datasets${i}-kmer-size_31_-abundance-min_2_-simple-dist_-complex-dist"
#	out=${PWD}/out${s}
#	mkdir -p ${out}
#	tmp=${PWD}/out${s}-tmp
#	mkdir -p ${tmp}
#	~/github/GATB/simka/build/bin/simka -in ${PWD}/datasets${i} -out ${out} -out-tmp ${tmp} -kmer-size 31 -abundance-min 2 -simple-dist -complex-dist
#	
#	
#	
#	s="-datasets${i}-kmer-size_15_-abundance-min_2_-simple-dist_-complex-dist"
#	out=${PWD}/out${s}
#	mkdir -p ${out}
#	tmp=${PWD}/out${s}-tmp
#	mkdir -p ${tmp}
#	~/github/GATB/simka/build/bin/simka -in ${PWD}/datasets${i} -out ${out} -out-tmp ${tmp} -kmer-size 15 -abundance-min 2 -simple-dist -complex-dist

i=-rmskonly
s="-datasets${i}-kmer-size_31_-abundance-min_2_-simple-dist_-complex-dist"
out=${PWD}/out${s}
mkdir -p ${out}
tmp=${PWD}/out${s}-tmp
mkdir -p ${tmp}
~/github/GATB/simka/build/bin/simka -in ${PWD}/datasets${i} -out ${out} -out-tmp ${tmp} -kmer-size 31 -abundance-min 2 -simple-dist -complex-dist



s="-datasets${i}-kmer-size_15_-abundance-min_2_-simple-dist_-complex-dist"
out=${PWD}/out${s}
mkdir -p ${out}
tmp=${PWD}/out${s}-tmp
mkdir -p ${tmp}
~/github/GATB/simka/build/bin/simka -in ${PWD}/datasets${i} -out ${out} -out-tmp ${tmp} -kmer-size 15 -abundance-min 2 -simple-dist -complex-dist

