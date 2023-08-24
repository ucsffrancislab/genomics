#!/usr/bin/env bash


dir=${PWD}/out
source_file=${PWD}/source.all.tsv
threads=32
mem=240

export SINGULARITY_BINDPATH=/francislab,/scratch
export APPTAINER_BINDPATH=/francislab,/scratch
export OMP_NUM_THREADS=${threads}
export IMOKA_MAX_MEM_GB=$((threads*(mem-1)))

#SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--dir)
			shift; dir=$1; shift;;
		-k|--k)
			shift; all_ks="${all_ks} $1"; shift;;
		--source_file)
			shift; source_file=$1; shift;;
#		--step)
#			shift; step=$1; shift;;
		--threads)
			shift; threads=$1; shift;;
		--mem)
			shift; mem=$1; shift;;
		*)
			shift;;
			#SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done



mkdir -p ${dir}
mkdir -p ${PWD}/logs

for k in ${all_ks} ; do

	echo $k

	date=$( date "+%Y%m%d%H%M%S%N" )

	#	A time limit of zero requests that no time limit be imposed.  Acceptable time formats include "minutes", "minutes:seconds", 
	#	"hours:minutes:sec‐onds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds".

	sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL \
		--job-name="iMOKA${k}" \
		--output="${PWD}/logs/iMOKA.${k}.${date}.out" \
		--time=14-0 --nodes=1 --ntasks=${threads} --mem=${mem}G \
		~/.local/bin/iMOKA.bash --dir ${dir}/${k} --k ${k} --source_file ${source_file} --stopstep reduce

done

