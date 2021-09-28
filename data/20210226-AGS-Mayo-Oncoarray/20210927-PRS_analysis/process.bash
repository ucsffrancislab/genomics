#!/usr/bin/env bash

IN=/francislab/data1/working/20210226-AGS-Mayo-Oncoarray/20210303-for_analysis
OUT=${PWD}/out

mkdir -p ${OUT}

#for chr in $( seq 1 22 ) ; do
for chr in 22 ; do
	echo $chr
	for phen_file in ${PWD}/PRS_blood_cell_*.txt ; do
		echo $phen_file
		phen=$( basename $phen_file .txt )
		phen=${phen#PRS_blood_cell_}
		echo $phen
		mkdir -p ${OUT}/${phen}

		sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL \
			--time=300 --nodes=1 --ntasks=4 --mem=30G \
			--job-name=${chr}_${phen} \
			--output="${OUT}/chr${chr}_${phen}.out" \
			plink2.bash \
				--pfile ${IN}/chr$chr.dose \
				--score $phen_file 6 7 8 header-read list-variants ignore-dup-ids cols=+scoresums \
				--memory 30000 \
				--threads 4 \
				--check ${OUT}/$phen/prs.$phen.$chr \
				--out ${OUT}/$phen/prs.$phen.$chr

	done
done



