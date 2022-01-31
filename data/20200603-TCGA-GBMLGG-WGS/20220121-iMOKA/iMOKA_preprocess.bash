#!/usr/bin/env bash

set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail
set -x


date=$( date "+%Y%m%d%H%M%S" )

k=31
threads=64
mem=7		#	per thread (keep 7)

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "

#The aggregate step always says that it can't find the matrix, but works.
#	setting SINGULARITY_BINDPATH instead of passing --bind seems to remedy?


while [ $# -gt 0 ] ; do
	case $1 in
		--dir)
			shift; dir=$1; shift;;
		--k)
			shift; k=$1; shift;;
		--source_file)
			shift; source_file=$1; shift;;
#		--step)
#			shift; step=$1; shift;;
#		--threads)
#			shift; threads=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=${threads}

export IMOKA_MAX_MEM_GB=$((threads*(mem-1)))
echo "IMOKA_MAX_MEM_GB=${IMOKA_MAX_MEM_GB}"
export sbatch_mem=$((threads*mem))G
echo "sbatch_mem=${sbatch_mem}"


mkdir -p ${dir}
cp ${source_file} ${dir}/source.tsv
cp ${PWD}/config.json ${dir}/
cd ${dir}	# preprocess creates a dir "preprocess" in working dir

${sbatch} --export=SINGULARITY_BINDPATH --parsable --job-name=${k}iMOKApreprocess \
	--time=5760 --nodes=1 --ntasks=${threads} --mem=${sbatch_mem} --output=${dir}/iMOKA.preprocess.${date}.txt \
	--wrap="singularity exec ${img} preprocess.sh --input-file ${dir}/source.tsv --kmer-length ${k} --ram $((threads*mem)) --threads ${threads}"


