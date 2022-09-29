#!/usr/bin/env bash

for k in 11 16 21 31 ; do

#	for s in 14a 14b 14c ; do

		for t in PrimaryRecurrent PrimaryRecurrentControl TumorControl ; do

			date=$( date "+%Y%m%d%H%M%S%N" )
			#sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${k}${s}${t}iMOKA" --output="${PWD}/logs/iMOKA.${k}.${s}.${t}.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/${t}/${k}/${s} --k ${k} --step create 
			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${k}${t}iMOKA" --output="${PWD}/logs/iMOKA.${k}.${t}.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/${t}/${k} --k ${k} --step create 

		done	#	t

#	done	#	s

done	#	k

