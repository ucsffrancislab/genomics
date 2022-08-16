#!/usr/bin/env bash

BOX_BASE="https://dav.box.com/dav/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )

BOX="${BOX_BASE}/${DATA}"
curl -netrc -X MKCOL "${BOX}/"
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
curl -netrc -X MKCOL "${BOX}/"

for k in 15 20 25 30 35 ; do
	BOX="${BOX_BASE}/${DATA}/${PROJECT}/${k}"
	curl -netrc -X MKCOL "${BOX}/"

	#	create_matrix.tsv - input samples used
	#	select_kmers.txt - kmers used by all of the models from the random forest models
	#	topredict.tsv - select kmer counts of unused samples
	#	predict_matrix.json - samples not used for models?
	#	*_RF.predictions.tsv - model predictions
	for f in create_matrix.tsv select_kmers.txt predict_matrix.json topredict.tsv ; do
		echo $f
		curl -netrc -T ${k}/${f} "${BOX}/"
	done
	for f in ${k}/*.predictions.tsv ; do
		echo $f
		curl -netrc -T ${f} "${BOX}/"
	done
done

