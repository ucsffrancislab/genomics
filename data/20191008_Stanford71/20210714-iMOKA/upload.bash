#!/usr/bin/env bash

BOX_BASE="https://dav.box.com/dav/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )

BOX="${BOX_BASE}/${DATA}"
curl -netrc -X MKCOL "${BOX}/"
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
curl -netrc -X MKCOL "${BOX}/"

#for f in metadata.csv ; do
#	echo $f
#	curl -netrc -T ${f} "${BOX}/"
#done

#for k in 11 16 21 31 ; do
for k in 16 ; do
#	for s in TumorControl PrimaryRecurrent PrimaryRecurrentControl ; do
		BOX="${BOX_BASE}/${DATA}/${PROJECT}/${k}"
		curl -netrc -X MKCOL "${BOX}/"
		#BOX="https://dav.box.com/dav/Francis _Lab_Share/20220610-EV/20220707-iMOKA/${s}-${k}"
		#curl -netrc -X MKCOL "${BOX}/"

		#curl -netrc -T ${k}.${s}.mers.txt "${BOX}/"
		#curl -netrc -T ${k}.${s}.raw.merged.csv.gz "${BOX}/"
		#curl -netrc -T ${k}.${s}.scaled.merged.csv.gz "${BOX}/"

		#	create_matrix.tsv - input samples used
		#	output_fi.tsv - combination of kmers and rankings
		#	aggregated.json - for the iMOKA desktop app
		#	output.json - for the iMOKA desktop app
		#	*_RF.predictions.tsv - model predictions
		#	select_kmers.txt - kmers used by all of the models from the random forest models
		#	predict_matrix.tsv - samples not used for models
		#	topredict.tsv - select kmer counts of unused samples
		#	matrix.tsv - select kmer counts of input samples
		for f in reduced.matrix create_matrix.tsv aggregated.json output.json output_fi.tsv select_kmers.txt predict_matrix.tsv topredict.tsv matrix.tsv ; do
			echo $f
			#curl -netrc -T ${s}/${k}/${f} "${BOX}/"
			curl -netrc -T ${k}/${f} "${BOX}/"
		done

		#for f in ${s}/${k}/output_models/*.predictions.tsv ; do
		for f in ${k}/output_models/*.predictions.tsv ; do
			echo $f
			curl -netrc -T ${f} "${BOX}/"
		done
#	done
done

