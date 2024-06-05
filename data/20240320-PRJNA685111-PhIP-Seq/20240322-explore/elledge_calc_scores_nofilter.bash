#!/usr/bin/env bash

sample=$1

#	sample_output_PED_9

for i in ${PWD}/Zscores/*.*.count.Zscores.${sample}.csv ; do

	elledge_calc_scores_nofilter.py $i /francislab/data1/refs/PhIP-Seq/VIR3_clean.csv.gz Species 7 | sort -t, -k1,1 > ${i%.csv}.virus_scores.csv

done

