#!/usr/bin/env bash

#/francislab/data1/working/1000genomes/20200311-viral_identification

for pheno_dir in blastn.viral.masked.unmapped/gwas/eur/pheno_files_* ; do
#for pheno_dir in blastn.viral.masked/gwas/eur/pheno_files_* ; do
#for pheno_dir in diamond.viral/gwas_all/eur/pheno_files_* ; do
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
