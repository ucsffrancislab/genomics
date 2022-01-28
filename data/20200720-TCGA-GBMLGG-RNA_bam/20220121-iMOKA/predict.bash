#!/usr/bin/env bash

export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

basedir=/francislab/data1/working/20200720-TCGA-GBMLGG-RNA_bam/20220121-iMOKA

#set -x

for k in 11 21 31 ; do
	for subset in 80a 80b 80c ; do
		echo $k $subset
		dir=${basedir}/IDH.${k}.${subset}

		#	Create a list of samples not included in the model creation that we wish to predict.
		diff -d ${basedir}/create_matrix.tsv <( sort ${basedir}/create_matrix.${subset}.tsv) | grep "^< " | sed 's/^< //' | sed "s'${basedir}'${dir}'" > ${dir}/predict_matrix.tsv

		#	Convert this tsv list into a json list
		#	Note that this json matrix is created with a rescale factor of 1e9 while those individuals are just 1.
		singularity exec ${img} iMOKA_core create -i ${dir}/predict_matrix.tsv -o ${dir}/predict_matrix.json

		#	I used output_fi.tsv to select mers, but the models use these features files. Most overlap but some do not.
		cat ${dir}/output_models/*.features | sort | uniq > ${dir}/select_kmers.txt

		echo "Extracting ..."
		singularity exec ${img} iMOKA_core extract -s ${dir}/predict_matrix.json -i ${dir}/select_kmers.txt -o ${dir}/topredict.tsv

		for model in ${dir}/output_models/*.pickle ; do
			echo $model
			model_name=${model%.pickle}
			singularity exec ${img} predict.py ${dir}/topredict.tsv ${model} ${model_name}.predictions.json | awk 'NR > 1 {print}' > ${model_name}.predictions.tsv
		done
	
		echo 'predictions completed'

	done
done

