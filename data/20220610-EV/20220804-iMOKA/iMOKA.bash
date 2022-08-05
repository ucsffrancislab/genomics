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
step="preprocess"
source_file="${PWD}/source.tsv"


export SINGULARITY_BINDPATH=/francislab,/scratch
export OMP_NUM_THREADS=${threads}
export IMOKA_MAX_MEM_GB=$((threads*(mem-1)))

dir="/francislab/data1/working/20220610-EV/20220804-iMOKA"	#/out"

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

#mkdir -p ${dir}


#WORKDIR=${TMPDIR}

#trap "{ chmod -R a+w $TMPDIR ; }" EXIT

WORKDIR=${dir}	#/out
mkdir -p ${WORKDIR}

date

cp /francislab/data1/refs/iMOKA/config.json ${WORKDIR}/

cd ${WORKDIR}

if [ "${step}" == "preprocess" ] ; then
	echo "Preprocessing"
	cp ${source_file} ${WORKDIR}/
	#	Copy raw data defined in source file???
		#--input-file ${source_file} \
	singularity exec ${img} preprocess.sh \
		--input-file source.tsv \
		--kmer-length ${k} \
		--ram $((threads*mem)) \
		--threads ${threads}
	#cp -r ${WORKDIR}/preprocess ${dir}/
	##	create_matrix.tsv will include the temp scratch path. 
	#cat ${WORKDIR}/create_matrix.tsv | sed "s'${WORKDIR}'${dir}'" > ${dir}/create_matrix.tsv
	step="create"
else
	echo "Skipping preprocessing. Copying in data."
	#sed "s'${dir}'${WORKDIR}'" ${dir}/create_matrix.tsv > ${WORKDIR}/create_matrix.tsv
	#cp -Lr ${dir}/preprocess ${WORKDIR}/
fi

date

if [ "${step}" == "create" ] ; then
	echo "Creating"
	singularity exec ${img} iMOKA_core create \
		--input ${WORKDIR}/create_matrix.tsv \
		--output ${WORKDIR}/matrix.json
	#cp ${WORKDIR}/matrix.json ${dir}/
	step="reduce"
else
	echo "Skipping create. Copying in matrix.json"
	#sed "s'/scratch/gwendt/[[:digit:]]*/'${WORKDIR}/'g" ${dir}/matrix.json > ${WORKDIR}/matrix.json
fi

date


#  iMOKA reduce [OPTION...]
#
#  -i, --input arg               The input matrix JSON header
#  -o, --output arg              Output matrix file
#  -h, --help                    Show this help
#  -a, --accuracy arg            Minimum of accuracy (default: 65)
#  -t, --test-percentage arg     The percentage of the min class used as test
#                                size (default: 0.25)
#  -e, --entropy-adjustment-down arg
#                                The adjustment value of the entropy filter
#                                that reduce the threshold. Need to be between 0
#                                and 1 not included, otherwise disable the
#                                entropy assertment. (default: 0.25)
#  -E, --entropy-adjustment-two arg
#                                The adjustment value of the entropy filter
#                                that increase the threshold. Need to be greater
#                                than 0, otherwise disable the entropy
#                                assertment. (default: 0.05)
#  -c, --cross-validation arg    Maximum number of cross validation (default:
#                                100)
#  -s, --standard-error arg      Standard error to achieve convergence in
#                                cross validation. Suggested between 0.5 and 2
#                                (default: 0.5)
#  -v, --verbose-entropy arg     Print the given number of k-mers for each
#                                thread, the entropy and the entropy threshold
#                                that would have been used as additional columns.
#                                Useful to evaluate the efficency of the
#                                entropy filter. Ignored if the entropy filter is
#                                disabled. Defualt: 0 ( Disabled ) (default: 0)
#  -m, --min arg                 Minimum raw count that at least one sample
#                                has to have to consider a k-mer (default: 5)
#  -S, --stable arg              Estimate the stable k-mers to use for
#                                independent normalization. 0 = Disable, N = number of
#                                stable k-mers (default: 10)

if [ "${step}" == "reduce" ] ; then
	echo "Reducing"
	singularity exec ${img} iMOKA_core reduce \
		--input ${WORKDIR}/matrix.json \
		--output ${WORKDIR}/reduced.matrix
	#	--accuracy 50 \
	#	--accuracy 1 \
	#	--standard-error 0.1 \
	#	--test-percentage 0.01 \
	#cp ${WORKDIR}/reduced.matrix* ${dir}/
	step="aggregate"
else
	echo "Skipping reduce. Copying in reduced matrix"
	#sed "s'/scratch/gwendt/[[:digit:]]*/'${WORKDIR}/'g" ${dir}/reduced.matrix.json > ${WORKDIR}/reduced.matrix.json
	#sed "1s'/scratch/gwendt/[[:digit:]]*/'${WORKDIR}/'g" ${dir}/reduced.matrix > ${WORKDIR}/reduced.matrix
fi

date

#Aggregate overlapping k-mers
#Usage:
#  iMOKA [OPTION...]
#
#  -i, --input arg               Input file containing the informations...
#  -o, --output arg              Basename of the output files (default:
#                                ./aggregated)
#  -h, --help                    Show this help
#  -w, --shift arg               Maximum shift considered during the edges
#                                creation (default: 1)
#  -t, --origin-threshold arg    Mininum value needed to create a graph
#                                (default: 80)
#  -T, --global-threshold arg    Global minimum value for whom the nodes will
#                                be used to build the graphs (default: 70)
#  -d, --de-coverage-threshold arg
#                                Consider ad differentially expressed a gene
#                                if at least one trascipt is covered for more
#                                than this threshold in sequences. (default: 50)
#  -m, --mapper-config arg       Mapper configuration JSON file (default:
#                                nomap)
#      --corr arg                Agglomerate k-mers with a correlation higher
#                                than this threshold and in the same gene or
#                                unmapped. (default: 1)
#  -C, --consistency arg         Consistency between nodes. The higher, the
#                                more different two sequential nodes can be.
#                                Minimum: 0.5 . Default: 1 (default: 2)
#  -c, --count-matrix arg        The count matrix. (default: nocount)
#  -p, --perfect-match           Don't consider sequences with mismatches or
#                                indels

if [ "${step}" == "aggregate" ] ; then
	echo "Aggregating"
	singularity exec ${img} iMOKA_core aggregate \
		--input ${WORKDIR}/reduced.matrix \
		--count-matrix ${WORKDIR}/matrix.json \
		--mapper-config ${WORKDIR}/config.json \
		--origin-threshold 50 \
		--output ${WORKDIR}/aggregated
		#--output ${WORKDIR}/aggregated \
		#--origin-threshold 95
	#cp ${WORKDIR}/aggregated* ${dir}/
	step="random_forest"
#else
fi

date

if [ "${step}" == "random_forest" ] ; then
	echo "Modeling"
	singularity exec ${img} random_forest.py \
		--threads ${threads} \
		-r 50 \
		${WORKDIR}/aggregated.kmers.matrix ${WORKDIR}/output
	#cp -r ${WORKDIR}/output* ${dir}/
#else
fi

echo "Complete"
date




















exit



Why did I un-scratch this script?


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/16 --k 16


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/21 --k 21


date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/31 --k 31



date=$( date "+%Y%m%d%H%M%S%N" )
sbatch --mail-user=$(tail -1 ~/.forward)  --mail-type=FAIL --job-name="iMOKA" --output="${PWD}/logs/iMOKA.${date}.out" --time=2880 --nodes=1 --ntasks=64 --mem=495G ${PWD}/iMOKA.bash --dir ${PWD}/11 --k 11 --step reduce



