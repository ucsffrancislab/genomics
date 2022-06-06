#!/usr/bin/env bash

export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
basedir=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220524-iMOKA

for k in 11 21 31 ; do
	for subset in 80a 80b 80c ; do
		dir=${basedir}/IDH.${k}.${subset}
		echo $k $subset
		sed -i "s'/[^,]*preprocess'${dir}/preprocess'g" ${dir}/matrix.json 
		singularity exec ${img} iMOKA_core extract -s ${dir}/matrix.json -i ${dir}/select_kmers.txt -o ${dir}/matrix.tsv
done ; done

