#!/usr/bin/env bash

#	https://github.com/RitchieLabIGH/iMOKA/blob/c150fe5c842966bbf33b709cf1563d70a1152de3/iMOKA/electron/iMOKA.js
#	https://github.com/RitchieLabIGH/iMOKA/blob/master/iMOKA_core/python/predict.py

img=/francislab/data2/refs/singularity/iMOKA_extended-1.1.5.img

for f in GBMWT GBMmut Oligo Astro ; do
for i in 1 2 3 4 5 ; do
	dir=cutadapt2.25.${f}.${i}
	sample_dir=/francislab/data1/working/20210428-EV/20211014-iMOKA/${dir}/preprocess
	model_base=/francislab/data1/working/20210428-EV/20211014-iMOKA/${dir}

	cat /francislab/data1/working/20210428-EV/20210830-iMOKA/cutadapt2.25/create_matrix.tsv \
  	| awk 'BEGIN{FS=OFS="\t"}( ((x[$3]++)%5+1)=='${i}' ){print}' \
  	| awk 'BEGIN{FS=OFS="\t"}($3!="'${f}'"){$3="non'${f}'"}{print}' > ${model_base}/predict_matrix.tsv

	singularity exec ${img} iMOKA_core create -i ${model_base}/predict_matrix.tsv -o ${model_base}/predict_matrix.json

	cat ${model_base}/output_models/*.features | sort | uniq > ${model_base}/features.ls

	singularity exec ${img} iMOKA_core extract -s ${model_base}/predict_matrix.json -i ${model_base}/features.ls -o ${model_base}/topredict.tsv

	for model in ${model_base}/output_models/*.pickle ; do
		model_name=${model%.pickle}
		singularity exec ${img} predict.py ${model_base}/topredict.tsv ${model} ${model_name}.predictions.json | awk ' NR > 1 {print}' > ${model_name}.predictions.tsv
	done

	echo 'predictions completed'
done ; done


#	mkdir -p "+sample_dir+"PRED/

#	echo '{ \"experiment\" : \""+model[0]+"\" ,  \"model\": \""+model[1]+"\", \"sample\" : \""+data.sample+"\" , ' > ./output
#	singularity exec ${img} awk ' /classnames/ { print; while ( (getline line ) > 0 && line !~ /]/ )  { print line } print line } ' ./tmp  >> ./output
#	echo '\"probabilities\" : [ ' >> ./output ")
#	singularity exec ${img} awk -F '\t' ' NR > 1 { print \",\" }  { line= \"[ \" $4 ; for (i = 5; i <= NF; i++ ) { line = line  \", \" $i  } ; print line \"]\" } END {print \" ] }\"}' ./predictions.tsv >> ./output ")
#	mv ./output "+sample_dir+"/PRED/"+model[0]+"_"+model[1]+".json")


