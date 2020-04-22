#!/usr/bin/env bash


WORK=/francislab/data1/working/1000genomes/20200311-viral_identification/bowtie2.hg38-masked-viruses

OUT=${WORK}/gwas_all

for pheno_dir in ${OUT}/*/pheno_files_* ; do
	for m in ${pheno_dir}/*.for.manhattan.plot ; do
		echo $m
		if [ -s "${m}" ] ; then
			echo "Processing ${m}"
			q=${m/manhattan/qq}
			manhattan_qq_plot.r -m ${m} -q ${q} -o ${pheno_dir}
		else
			echo "${m} is empty"
		fi
	done
done
