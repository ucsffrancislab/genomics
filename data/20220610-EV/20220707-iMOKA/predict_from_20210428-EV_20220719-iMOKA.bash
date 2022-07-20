#!/usr/bin/env bash

export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

basedir=/francislab/data2/working/20220610-EV/20220707-iMOKA
predictionsdir=${basedir}/predictions
mkdir -p ${predictionsdir}

modelbase=/francislab/data2/working/20210428-EV/20220719-iMOKA

#set -x


for k in 16 21 31 ; do

	ddir=${basedir}/${k}
	pdir=${predictionsdir}/${k}
	mkdir -p ${pdir}
	mdir=${modelbase}/${k}

	singularity exec ${img} iMOKA_core create -i ${ddir}/create_matrix.tsv -o ${pdir}/predict_matrix.json

	#	I used output_fi.tsv to select mers, but the models use these features files. Most overlap but some do not.
	cat ${mdir}/output_models/*.features | sort | uniq > ${pdir}/select_kmers.txt

	echo "Extracting ..."
	singularity exec ${img} iMOKA_core extract -s ${pdir}/predict_matrix.json -i ${pdir}/select_kmers.txt -o ${pdir}/topredict.tsv

	for model in ${mdir}/output_models/*.pickle ; do
		echo $model
		base_model_name=$( basename ${model} .pickle )
		singularity exec ${img} predict.py ${pdir}/topredict.tsv ${model} ${pdir}/${base_model_name}.predictions.json | awk 'NR > 1 {print}' > ${pdir}/${base_model_name}.predictions.tsv
	done
		
	echo 'predictions completed'
	
done

