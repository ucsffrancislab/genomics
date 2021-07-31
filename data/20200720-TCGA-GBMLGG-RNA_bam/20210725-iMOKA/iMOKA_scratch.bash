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
img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.3.img
k=31
mem=7		#	per thread (keep 7)


export SINGULARITY_BINDPATH=/francislab,/scratch
export OMP_NUM_THREADS=${threads}
# export IMOKA_MAX_MEM_GB=$((threads*(mem-2)))
export IMOKA_MAX_MEM_GB=$((threads*(mem-1)))


SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--dir)
			shift; dir=$1; shift;;
		--threads)
			shift; threads=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

trap "{ chmod -R a+w $TMPDIR ; }" EXIT


#	Copy source file?
#	Copy raw data?
#
#  singularity exec ${img} preprocess.sh --input-file ${kdir}/source.tsv --kmer-length ${k} --ram $((threads*mem)) --threads ${threads}




date

#	For the moment this is the "create" and "reduce" step

cp ${dir}/config.json ${TMPDIR}/

cp -Lr ${dir}/preprocess ${TMPDIR}/

cat ${dir}/create_matrix.tsv | sed "s'${dir}'${TMPDIR}'" > ${TMPDIR}/create_matrix.tsv

singularity exec ${img} iMOKA_core create --input ${TMPDIR}/create_matrix.tsv --output ${TMPDIR}/matrix.json

cp ${TMPDIR}/matrix.json ${dir}/

date

singularity exec ${img} iMOKA_core reduce --input ${TMPDIR}/matrix.json --output ${TMPDIR}/reduced.matrix

cp ${TMPDIR}/reduced.matrix* ${dir}/

date

singularity exec ${img} iMOKA_core aggregate --input ${TMPDIR}/reduced.matrix --count-matrix ${TMPDIR}/matrix.json --mapper-config ${TMPDIR}/config.json --output ${TMPDIR}/aggregated

cp ${TMPDIR}/aggregated* ${dir}/

date

singularity exec ${img} random_forest.py --threads ${threads} -r 50 ${TMPDIR}/aggregated.kmers.matrix ${TMPDIR}/output

cp -r ${TMPDIR}/output* ${dir}/

date




exit



date=$( date "+%Y%m%d%H%M%S" )
sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
${sbatch} --job-name=TiMOKAscratch --time=11520 --nodes=1 --ntasks=32 --mem=240G --gres=scratch:1500G --output=${PWD}/iMOKA_scratch.31.gender_test.${date}.txt ${PWD}/iMOKA_scratch.bash --dir ${PWD}/31.gender_test



date=$( date "+%Y%m%d%H%M%S" )
sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
${sbatch} --job-name=TiMOKAscratch --time=20160 --nodes=1 --ntasks=64 --mem=499G --gres=scratch:1500G --output=${PWD}/iMOKA_scratch.31.primary_diagnosis.${date}.txt ${PWD}/iMOKA_scratch.bash --dir ${PWD}/31.primary_diagnosis

date=$( date "+%Y%m%d%H%M%S" )
sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
${sbatch} --job-name=TiMOKAscratch --time=20160 --nodes=1 --ntasks=64 --mem=499G --gres=scratch:1500G --output=${PWD}/iMOKA_scratch.31.gender.${date}.txt ${PWD}/iMOKA_scratch.bash --dir ${PWD}/31.gender


date=$( date "+%Y%m%d%H%M%S" )
sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "
${sbatch} --job-name=WHO_groups --time=20160 --nodes=1 --ntasks=64 --mem=499G --gres=scratch:1500G --output=${PWD}/iMOKA_scratch.31.WHO_groups.${date}.txt ${PWD}/iMOKA_scratch.bash --dir ${PWD}/31.WHO_groups


