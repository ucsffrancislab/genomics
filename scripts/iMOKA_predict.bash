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
#k=21
mem=7		#	per thread (keep 7)
#step="preprocess"
#source_file="${PWD}/source.tsv"

#dir="/francislab/data1/working/20220610-EV/20220914-iMOKA"	#/out"

dir=${PWD}

SELECT_ARGS=""
while [ $# -gt 0 ] ; do
	case $1 in
		--predict_matrix)
			shift; predict_matrix=$1; shift;;
		--model_base)
			shift; model_base=$1; shift;;
		--predict_out)
			shift; predict_out=$1; shift;;
#		--step)
#			shift; step=$1; shift;;
		--threads)
			shift; threads=$1; shift;;
		*)
			SELECT_ARGS="${SELECT_ARGS} $1"; shift;;
	esac
done

export SINGULARITY_BINDPATH=/francislab,/scratch
export APPTAINER_BINDPATH=/francislab,/scratch
export OMP_NUM_THREADS=${threads}
export IMOKA_MAX_MEM_GB=$((threads*(mem-1)))



date



  
#	create ${predict_out}/predict_matrix.tsv
#ln -s ${predict_in}/create_matrix.tsv ${predict_out}/predict_matrix.tsv


#	Convert this tsv list into a json list
#	Note that this json matrix is created with a rescale factor of 1e9 while those individuals are just 1.

#	could pass rescale factor of 1e9? 

singularity exec ${img} iMOKA_core create \
	-i ${predict_matrix} \
	-o ${predict_out}/predict_matrix.json

#	I used output_fi.tsv to select mers, but the models use these features files. Most overlap but some do not.
cat ${model_base}/output_models/*.features | sort | uniq > ${predict_out}/select_kmers.txt

echo "Extracting ..."
singularity exec ${img} iMOKA_core extract \
	-s ${predict_out}/predict_matrix.json \
	-i ${predict_out}/select_kmers.txt \
	-o ${predict_out}/topredict.tsv

for model in ${model_base}/output_models/*.pickle ; do
#for model in ${model_base}/*.pickle ; do
	echo $model
	model_name=${model%.pickle}

	#singularity exec ${img} predict.py ${predict_out}/topredict.tsv ${model} ${model_name}.predictions.json \
	#	| awk 'NR > 1 {print}' > ${model_name}.predictions.tsv

	#mkdir -p ${predict_out}/
	singularity exec ${img} predict.py ${predict_out}/topredict.tsv ${model} ${model_name}.predictions.json \
		| tail -n +2 > ${predict_out}/$( basename ${model_name} ).predictions.tsv

	mv ${model_name}.predictions.json ${predict_out}/

done



echo "Complete"
date


