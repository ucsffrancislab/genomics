#!/usr/bin/env bash

# RUN METAL ON ALL SUBTYPES

server=$1
f=$2

#	echo ${PWD}
#	dir="/francislab/data1/working/20250800-AGS-CIDR-ONCO-I370-TCGA/20250723-survival_gwas"
#	echo ${dir}
#	dir=${PWD}

FILE=script_Pharma_survival_metal_spa_all3.txt

subset=$( basename $f .txt )
subset=${subset#onco_}

echo $subset

sed -e "s/SERVER/${server}/g" -e "s/_SUBSETNAME/_${subset}/g" ${PWD}/${FILE} > $TMPDIR/$( basename $FILE )

cat $TMPDIR/$( basename $FILE )

echo metal $TMPDIR/$( basename $FILE )
metal $TMPDIR/$( basename $FILE ) > ${PWD}/spa_meta_survival_${server}_${subset}_1.log

head -1 spa_meta_survival_${server}_${subset}_1.tbl > spa_meta_survival_${server}_${subset}_1.10k.tbl 
tail -n +2 spa_meta_survival_${server}_${subset}_1.tbl | sort -t $'\t' -k10g,10 | head -10000 >> spa_meta_survival_${server}_${subset}_1.10k.tbl 

