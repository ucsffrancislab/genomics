#!/usr/bin/env bash


for b in i370 onco tcga ; do
	tsv=imputed-topmed-${b}/${b}-cases/${b}-covariates.tsv

	echo $tsv
	for f in sex idh idhmut tert source chemo rad ngrade idhmut_gwas idhwt_gwas ; do
		echo $f
		i=$( head -1 ${tsv} | tr '\t' '\n' | awk -v f=${f} '( $0 == f ){print NR}' )
		if [ -n "${i}" ] ; then
			cut -f${i} ${tsv} | tail -n +2 | sort | uniq -c
		fi

	done

done


