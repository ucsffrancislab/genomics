#!/usr/bin/env bash

#export SINGULARITY_BINDPATH=/francislab
export APPTAINER_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
basedir=${PWD}/out	#/francislab/data1/working/20220610-EV/20220707-iMOKA

for k in 11 16 21 31 ; do
	for s in 14a 14b 14c ; do
		for t in TumorControl PrimaryRecurrent PrimaryRecurrentControl ; do
			dir=${basedir}/${t}/${k}/${s}
			echo $k $s $t
			#sed -i "s'/[^,]*preprocess'${dir}/preprocess'g" ${dir}/matrix.json 
			singularity exec ${img} iMOKA_core extract -s ${dir}/matrix.json -i ${dir}/select_kmers.txt -o ${dir}/matrix.tsv
		done	#	t
	done	#	s
done	#	k

