#!/usr/bin/env bash

#for k in 11 16 21 26 31 ; do
for k in 11 ; do

	#for s in a b c ; do
	for s in a ; do

		for t in HLvA HAvL ; do

			date=$( date "+%Y%m%d%H%M%S%N" )
			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${k}${s}${t}iMOKA" \
				--output="${PWD}/logs/iMOKA.${k}.${s}.${t}.${date}.out" --time=360 \
				--nodes=1 --ntasks=32 --mem=240G \
				~/.local/bin/iMOKA.bash --dir ${PWD}/${t}/${k}/${s} --k ${k} --step create \
					--reduce --test-percentage 0.3 \
					--reduce --accuracy 1 \
					--reduce --standard-error 2 \
					--reduce --min 1 \
					--reduce --stable 5 \
					--reduce --entropy-adjustment-down -1 \
					--reduce --entropy-adjustment-two -1 \
					--random_forest --cross-validation 3

		done	#	t

	done	#	s

done	#	k

