#!/usr/bin/env bash

mkdir -p ${PWD}/logs

for k in 11 16 21 26 31 ; do

	date=$( date "+%Y%m%d%H%M%S%N" )
	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--job-name="iMOKA${k}" \
		--output="${PWD}/logs/iMOKA.${k}.${date}.out" \
		--time=60 --nodes=1 --ntasks=32 --mem=240G \
		~/.local/bin/iMOKA.bash --dir ${PWD}/${k} --k ${k} --source_file ${PWD}/source.tsv --stopstep reduce

done

