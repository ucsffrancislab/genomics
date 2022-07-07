#!/usr/bin/env bash

export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

basedir=/francislab/data2/working/20220610-EV/20220707-iMOKA

#set -x


for k in 11 16 21 31 ; do
	for r in TumorControl PrimaryRecurrent PrimaryRecurrentControl ; do
#	for subset in 80a 80b 80c ; do
#		echo $k $subset
		dir=${basedir}/${k}
		rdir=${basedir}/${r}/${k}

#		dir=${basedir}/IDH.${k}.${subset}
#
#		#	Create a list of samples not included in the model creation that we wish to predict.
#		#diff -d ${basedir}/create_matrix.tsv <( sort ${basedir}/create_matrix.${subset}.tsv) | grep "^< " | sed 's/^< //' | sed "s'${basedir}'${dir}'" > ${dir}/predict_matrix.tsv
#		#diff -d ${basedir}/create_matrix.tsv <( sort ${basedir}/create_matrix.${subset}.tsv) | grep "^< " | sed 's/^< //' > ${dir}/predict_matrix.tsv
#
#		diff -d ${basedir}/create_matrix.tsv <( sort ${basedir}/create_matrix.${subset}.tsv) | grep "^< " | sed 's/^< //'  | sed "s'${basedir}/IDH.11'${dir}'" > ${dir}/predict_matrix.tsv



		diff -d ${dir}/create_matrix.tsv ${rdir}/create_matrix.tsv | grep "^< " | sed 's/^< //' | grep -vs "Test SE" | grep -vs "SFHH011B.tsv" > ${rdir}/predict_matrix.tsv

				

		#	Convert this tsv list into a json list
		#	Note that this json matrix is created with a rescale factor of 1e9 while those individuals are just 1.

		#	could pass rescale factor of 1e9? 

		singularity exec ${img} iMOKA_core create -i ${rdir}/predict_matrix.tsv -o ${rdir}/predict_matrix.json


		#	I used output_fi.tsv to select mers, but the models use these features files. Most overlap but some do not.
		cat ${rdir}/output_models/*.features | sort | uniq > ${rdir}/select_kmers.txt

		echo "Extracting ..."
		singularity exec ${img} iMOKA_core extract -s ${rdir}/predict_matrix.json -i ${rdir}/select_kmers.txt -o ${rdir}/topredict.tsv

		for model in ${rdir}/output_models/*.pickle ; do
			echo $model
			model_name=${model%.pickle}
			singularity exec ${img} predict.py ${rdir}/topredict.tsv ${model} ${model_name}.predictions.json | awk 'NR > 1 {print}' > ${model_name}.predictions.tsv
		done
	
		echo 'predictions completed'

	done
done

