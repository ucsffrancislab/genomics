#!/usr/bin/env bash

#export SINGULARITY_BINDPATH=/francislab
export APPTAINER_BINDPATH=/francislab
export OMP_NUM_THREADS=16
export IMOKA_MAX_MEM_GB=96

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

#basedir=/francislab/data2/working/20220610-EV/20220707-iMOKA
basedir=${PWD}/out

#set -x


for k in 11 16 21 31 ; do
	for s in 14a 14b 14c ; do
		for t in TumorControl PrimaryRecurrent PrimaryRecurrentControl ; do
			echo $k $s $t
			#dir=${basedir}/${k}/${s}
			dir=${basedir}/${k}
			rdir=${basedir}/${t}/${k}/${s}

			#diff -d <( sort ${dir}/create_matrix.tsv ) <( sort ${rdir}/create_matrix.tsv ) | grep "^< " | sed 's/^< //' | grep -vs "Test SE" | grep -vs "SFHH011B.tsv" > ${rdir}/predict_matrix.tsv


#			diff -d <( sort ${dir}/create_matrix.tsv ) <( sort ${rdir}/create_matrix.tsv ) | grep "^< " | sed 's/^< //' | grep -vs "SFHH011B.tsv" > ${rdir}/predict_matrix.tsv

			if [ $t == "TumorControl" ] ; then
				diff -d <( sort ${dir}/create_matrix.tsv ) <( sort ${rdir}/create_matrix.tsv ) | grep "^< " | sed 's/^< //' | \
					grep -vs -E "scan|stable|pre-progression" | \
					sed -E 's/\t(post-recurrence|pre-surg|primary|progression|recurence|scan|Primary|Recurrent)$/\ttumor/' | \
					sed -E 's/\t(Test-SE)$/\tcontrol/' | \
					grep -vs "SFHH011B.tsv" > ${rdir}/predict_matrix.tsv
			elif [ $t == "PrimaryRecurrent" ] ; then
				diff -d <( sort ${dir}/create_matrix.tsv ) <( sort ${rdir}/create_matrix.tsv ) | grep "^< " | sed 's/^< //' | \
					grep -vs -E "scan|stable|pre-progression" | \
					sed -E 's/\t(pre-surg|primary)$/\tPrimary/' | \
					sed -E 's/\t(post-recurrence|progression|recurence)$/\tRecurrent/' | \
					grep -vs "Test-SE" | grep -vs "control" | \
					grep -vs "SFHH011B.tsv" > ${rdir}/predict_matrix.tsv
			elif [ $t == "PrimaryRecurrentControl" ] ; then
				diff -d <( sort ${dir}/create_matrix.tsv ) <( sort ${rdir}/create_matrix.tsv ) | grep "^< " | sed 's/^< //' | \
					grep -vs -E "scan|stable|pre-progression" | \
					sed -E 's/\t(pre-surg|primary)$/\tPrimary/' | \
					sed -E 's/\t(post-recurrence|progression|recurence)$/\tRecurrent/' | \
					sed -E 's/\t(Test-SE)$/\tcontrol/' | \
					grep -vs "SFHH011B.tsv" > ${rdir}/predict_matrix.tsv
			else
				echo "Not sure what happened"
				exit 
			fi


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
				singularity exec ${img} predict.py ${rdir}/topredict.tsv ${model} ${model_name}.predictions.json | \
					awk 'NR > 1 {print}' > ${model_name}.predictions.tsv
			done
	
			echo 'predictions completed'

		done	#	t
	done	#	s
done	#	k

