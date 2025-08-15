#!/usr/bin/env bash

# RUN METAL ON ALL SUBTYPES


FILE=script_Pharma_survival_metal_spa_all3.txt

for f in /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250723-survival_gwas/lists/onco*meta*_cases.txt ; do

	subset=$( basename $f .txt )
	subset=${subset#onco_}

	echo $subset

	sed "s/_SUBSETNAME/_${subset}/g" /francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250723-survival_gwas/${FILE} > $TMPDIR/$( basename $FILE )

	cat $TMPDIR/$( basename $FILE )

	echo ./generic-metal/metal $TMPDIR/$( basename $FILE )

done

