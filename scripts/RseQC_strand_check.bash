#!/usr/bin/env bash


#	base=/francislab/data1/working/20201006-GTEx/20240618-STAR_twopass_basic-hg38_v25/out
#	dir=${base}/strand_check
#	mkdir ${dir}
#	for bai in ${base}/*Aligned.sortedByCoord.out.bam.bai; do
#	bam=${bai%%.bai}
#	echo $bam
#	f=${dir}/$(basename ${bai} .bam.bai).strand_check.txt
#	if [ ! -f ${f} ] ; then infer_experiment.py -r /francislab/data1/refs/RseQC/hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f} ; fi
#	done


f=${dir}/$(basename ${bai} .bam.bai).strand_check.txt

if [ ! -f ${f} ] ; then 
	infer_experiment.py -r /francislab/data1/refs/RseQC/hg38_GENCODE_V42_Basic.bed -i ${bam} > ${f}
fi


