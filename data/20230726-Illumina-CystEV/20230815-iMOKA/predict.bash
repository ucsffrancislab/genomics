#!/usr/bin/env bash

export SINGULARITY_BINDPATH=/francislab
export APPTAINER_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

basedir=${PWD}

#set -x


#for k in 13 16 21 31 35 39 43 ; do

#for kdir in ${basedir}/out/?? ; do
for kdir in ${basedir}/out/11 ; do

	k=$( basename $kdir )

	for var in grade_collapsed ; do

			model_dir=${basedir}/out/${var}-${k}

			predict_in=${basedir}/predictions/${k}

			predict_out=${basedir}/predictions/${var}-${k}
			mkdir -p ${predict_out}

#	#		#	Create a list of samples not included in the model creation that we wish to predict.
#	#		#diff -d ${basedir}/create_matrix.tsv <( sort ${basedir}/create_matrix.${subset}.tsv) | grep "^< " | sed 's/^< //' | sed "s'${basedir}'${dir}'" > ${dir}/predict_matrix.tsv
#	#		#diff -d ${basedir}/create_matrix.tsv <( sort ${basedir}/create_matrix.${subset}.tsv) | grep "^< " | sed 's/^< //' > ${dir}/predict_matrix.tsv
#	#
#	#		diff -d ${basedir}/create_matrix.tsv <( sort ${basedir}/create_matrix.${subset}.tsv) | grep "^< " | sed 's/^< //'  | sed "s'${basedir}/IDH.11'${dir}'" > ${dir}/predict_matrix.tsv
#	
#	
#	
#			diff -d ${dir}/create_matrix.tsv ${rdir}/create_matrix.tsv | grep "^< " | sed 's/^< //' | grep -vs "Test SE" | grep -vs "SFHH011B.tsv" > ${rdir}/predict_matrix.tsv
#	


		#	create ${predict_out}/predict_matrix.tsv
		ln -s ${predict_in}/create_matrix.tsv ${predict_out}/predict_matrix.tsv


		#	Convert this tsv list into a json list
		#	Note that this json matrix is created with a rescale factor of 1e9 while those individuals are just 1.

		#	could pass rescale factor of 1e9? 

		singularity exec ${img} iMOKA_core create \
			-i ${predict_out}/predict_matrix.tsv \
			-o ${predict_out}/predict_matrix.json

		#	I used output_fi.tsv to select mers, but the models use these features files. Most overlap but some do not.
		cat ${model_dir}/output_models/*.features | sort | uniq > ${predict_out}/select_kmers.txt

		echo "Extracting ..."
		singularity exec ${img} iMOKA_core extract \
			-s ${predict_out}/predict_matrix.json \
			-i ${predict_out}/select_kmers.txt \
			-o ${predict_out}/topredict.tsv

		for model in ${model_dir}/output_models/*.pickle ; do
			echo $model
			model_name=${model%.pickle}
			#singularity exec ${img} predict.py ${predict_out}/topredict.tsv ${model} ${model_name}.predictions.json \
			#	| awk 'NR > 1 {print}' > ${model_name}.predictions.tsv
			mkdir -p ${predict_out}/
			singularity exec ${img} predict.py ${predict_out}/topredict.tsv ${model} ${model_name}.predictions.json \
				| tail -n +2 > ${predict_out}/$(basename ${model_name} ).predictions.tsv
		done

		echo 'predictions completed'

	done	#	var

done	#	k

