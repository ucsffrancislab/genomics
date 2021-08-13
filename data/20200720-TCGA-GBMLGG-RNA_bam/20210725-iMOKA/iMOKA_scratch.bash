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
img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.4.img
k=31
mem=7		#	per thread (keep 7)
step="preprocess"
source_file="${PWD}/source.tsv"


export SINGULARITY_BINDPATH=/francislab,/scratch
export OMP_NUM_THREADS=${threads}
export IMOKA_MAX_MEM_GB=$((threads*(mem-1)))


SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--dir)
			shift; dir=$1; shift;;
		--k)
			shift; k=$1; shift;;
		--source_file)
			shift; source_file=$1; shift;;
		--step)
			shift; step=$1; shift;;
		--threads)
			shift; threads=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done


trap "{ chmod -R a+w $TMPDIR ; }" EXIT

date

cp ${dir}/config.json ${TMPDIR}/


if [ "${step}" == "preprocess" ] ; then
	echo "Preprocessing"
	cp ${source_file} ${TMPDIR}/
	#	Copy raw data defined in source file???
	singularity exec ${img} preprocess.sh \
		--input-file ${source_file} \
		--kmer-length ${k} \
		--ram $((threads*mem)) \
		--threads ${threads}
	cp -r ${TMPDIR}/preprocess ${dir}/
	##	create_matrix.tsv will include the temp scratch path. 
	cat ${TMPDIR}/create_matrix.tsv | sed "s'${TMPDIR}'${dir}'" > ${dir}/create_matrix.tsv
	step="create"
else
	echo "Skipping preprocessing. Copying in data."
	sed "s'${dir}'${TMPDIR}'" ${dir}/create_matrix.tsv > ${TMPDIR}/create_matrix.tsv
	cp -Lr ${dir}/preprocess ${TMPDIR}/
fi

date

if [ "${step}" == "create" ] ; then
	echo "Creating"
	singularity exec ${img} iMOKA_core create \
		--input ${TMPDIR}/create_matrix.tsv \
		--output ${TMPDIR}/matrix.json
	cp ${TMPDIR}/matrix.json ${dir}/
	step="reduce"
else
	echo "Skipping create. Copying in matrix.json"
	sed "s'/scratch/gwendt/[[:digit:]]*/'${TMPDIR}/'g" ${dir}/matrix.json > ${TMPDIR}/matrix.json
fi

date

if [ "${step}" == "reduce" ] ; then
	echo "Reducing"
	singularity exec ${img} iMOKA_core reduce \
		--input ${TMPDIR}/matrix.json \
		--output ${TMPDIR}/reduced.matrix
	cp ${TMPDIR}/reduced.matrix* ${dir}/
	step="aggregate"
else
	echo "Skipping reduce. Copying in reduced matrix"
	sed "s'/scratch/gwendt/[[:digit:]]*/'${TMPDIR}/'g" ${dir}/reduced.matrix.json > ${TMPDIR}/reduced.matrix.json
	sed "1s'/scratch/gwendt/[[:digit:]]*/'${TMPDIR}/'g" ${dir}/reduced.matrix > ${TMPDIR}/reduced.matrix
fi

date

if [ "${step}" == "aggregate" ] ; then
	echo "Aggregating"
	singularity exec ${img} iMOKA_core aggregate \
		--input ${TMPDIR}/reduced.matrix \
		--count-matrix ${TMPDIR}/matrix.json \
		--mapper-config ${TMPDIR}/config.json \
		--output ${TMPDIR}/aggregated \
		--origin-threshold 95
	cp ${TMPDIR}/aggregated* ${dir}/
	step="random_forest"
#else
fi

date

if [ "${step}" == "random_forest" ] ; then
	echo "Modeling"
	singularity exec ${img} random_forest.py \
		--threads ${threads} \
		-r 50 \
		${TMPDIR}/aggregated.kmers.matrix ${TMPDIR}/output
	cp -r ${TMPDIR}/output* ${dir}/
#else
fi

echo "Complete"
date

exit



date=$( date "+%Y%m%d%H%M%S" )
sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
${sbatch} --job-name=TiMOKAscratch --time=11520 --nodes=1 --ntasks=32 --mem=240G --gres=scratch:1500G --output=${PWD}/iMOKA_scratch.31.gender_test.${date}.txt ${PWD}/iMOKA_scratch.bash --dir ${PWD}/31.gender_test





date=$( date "+%Y%m%d%H%M%S" )
sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
${sbatch} --job-name=TiMOKAscratch --time=20160 --nodes=1 --ntasks=64 --mem=499G --gres=scratch:1500G --output=${PWD}/31.primary_diagnosis/iMOKA_scratch.${date}.txt ${PWD}/iMOKA_scratch.bash --dir ${PWD}/31.primary_diagnosis --step create


date=$( date "+%Y%m%d%H%M%S" )
sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
${sbatch} --job-name=WHO_groups --time=20160 --nodes=1 --ntasks=64 --mem=499G --gres=scratch:1500G --output=${PWD}/31.WHO_groups/iMOKA_scratch.${date}.txt ${PWD}/iMOKA_scratch.bash --dir ${PWD}/31.WHO_groups --step create


date=$( date "+%Y%m%d%H%M%S" )
sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
${sbatch} --job-name=IDH --time=20160 --nodes=1 --ntasks=64 --mem=499G --gres=scratch:1500G --output=${PWD}/31.IDH/iMOKA_scratch.${date}.txt ${PWD}/iMOKA_scratch.bash --dir ${PWD}/31.IDH --step create


