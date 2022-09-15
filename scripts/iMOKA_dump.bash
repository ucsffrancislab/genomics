#!/usr/bin/env bash
#SBATCH --export=NONE   # required when using 'module' IN THIS SCRIPT OR ANY THAT ARE CALLED

hostname

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail
if [ -n "$( declare -F module )" ] ; then
	echo "Loading required modules"
	#module load CBI samtools
fi
set -x

threads=${SLURM_NTASKS:-1}
img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img
k=21
mem=7		#	per thread (keep 7)
#step="preprocess"
#source_file="${PWD}/source.tsv"


export SINGULARITY_BINDPATH=/francislab,/scratch
export OMP_NUM_THREADS=${threads}
export IMOKA_MAX_MEM_GB=$((threads*(mem-1)))

#dir="/francislab/data1/working/20220610-EV/20220914-iMOKA"	#/out"

dir=${PWD}

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--dir)
			shift; dir=$1; shift;;
#		--k)
#			shift; k=$1; shift;;
#		--source_file)
#			shift; source_file=$1; shift;;
#		--step)
#			shift; step=$1; shift;;
		--threads)
			shift; threads=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

#mkdir -p ${dir}


#WORKDIR=${TMPDIR}

#trap "{ chmod -R a+w $TMPDIR ; }" EXIT

#WORKDIR=${dir}	#/out
#mkdir -p ${WORKDIR}

#date


#cd ${WORKDIR}

date


#singularity exec ${img} iMOKA_core dump -i ${PWD}/${k}/create_matrix.json -o ${PWD}/${k}/kmer_matrix.tsv
#gzip ${PWD}/${k}/kmer_matrix.tsv


mkdir -p ${dir}
singularity exec ${img} iMOKA_core dump -i ${dir}/create_matrix.json -o ${dir}/kmer_matrix.tsv
gzip ${dir}/kmer_matrix.tsv


echo "Complete"
date


