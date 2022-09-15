#!/usr/bin/env bash

for k in 11 16 21 31 ; do

	for s in 14a 14b 14c ; do

		for t in PrimaryRecurrent PrimaryRecurrentControl TumorControl ; do

			date=$( date "+%Y%m%d%H%M%S%N" )
			sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="${k}${s}${t}iMOKA" --output="${PWD}/logs/iMOKA.${k}.${s}.${t}.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/${t}/${k}/${s} --k ${k} --step create 

		done

#		date=$( date "+%Y%m%d%H%M%S%N" )
#		sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA${k}${s}" --output="${PWD}/logs/iMOKA.${k}.${s}.primary_recurrent.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrent/${k}/${s} --k ${k} --step create 
#	#--source_file ${PWD}/source.primaryrecurrent.tsv
#
#
#		date=$( date "+%Y%m%d%H%M%S%N" )
#		sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA${k}${s}" --output="${PWD}/logs/iMOKA.${k}.${s}.primary_recurrent_control.${date}.out" --time=360 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/PrimaryRecurrentControl/${k}/${s} --k ${k} --step create 
#	#--source_file ${PWD}/source.primaryrecurrentcontrol.tsv
#
#
#		date=$( date "+%Y%m%d%H%M%S%N" )
#		sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA${k}${s}" --output="${PWD}/logs/iMOKA.${k}.${s}.tumor_control.${date}.out" --time=720 --nodes=1 --ntasks=32 --mem=240G ~/.local/bin/iMOKA.bash --dir ${PWD}/TumorControl/${k}/${s} --k ${k} --step create 
	#--source_file ${PWD}/source.tumorcontrol.tsv

	done

done

