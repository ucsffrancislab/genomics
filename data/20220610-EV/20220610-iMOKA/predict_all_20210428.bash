#!/usr/bin/env bash

export SINGULARITY_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

basedir=/francislab/data2/working/20220610-EV/20220610-iMOKA

outdir=/francislab/data2/working/20220610-EV/20220610-iMOKA/predictions

modelbase=/francislab/data2/working/20210428-EV/20220614-iMOKA

#set -x


for k in 10 16 21 31 ; do

	ddir=${basedir}/${k}
	odir=${outdir}/${k}
	mkdir -p ${odir}
	mdir=${modelbase}/${k}

	cat ${ddir}/create_matrix.tsv | sed 's/^< //' | grep -vs "Test SE" | grep -vs "SFHH011B.tsv" > ${odir}/predict_matrix.tsv

	singularity exec ${img} iMOKA_core create -i ${odir}/predict_matrix.tsv -o ${odir}/predict_matrix.json

	#	I used output_fi.tsv to select mers, but the models use these features files. Most overlap but some do not.
	cat ${mdir}/output_models/*.features | sort | uniq > ${odir}/select_kmers.txt

	echo "Extracting ..."
	singularity exec ${img} iMOKA_core extract -s ${odir}/predict_matrix.json -i ${odir}/select_kmers.txt -o ${odir}/topredict.tsv

	for model in ${mdir}/output_models/*.pickle ; do
		echo $model
		base_model_name=$( basename ${model} .pickle )
		singularity exec ${img} predict.py ${odir}/topredict.tsv ${model} ${odir}/${base_model_name}.predictions.json | awk 'NR > 1 {print}' > ${odir}/${base_model_name}.predictions.tsv
	done
		
	echo 'predictions completed'
	
done

