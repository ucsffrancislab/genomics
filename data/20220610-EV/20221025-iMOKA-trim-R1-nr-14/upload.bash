#!/usr/bin/env bash

#BOX_BASE="https://dav.box.com/dav/Francis _Lab_Share"
BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"

PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )

BOX="${BOX_BASE}/${DATA}"
#curl -netrc -X MKCOL "${BOX}/"
#curl -netrc --ftp-create-dirs "${BOX}/"
BOX="${BOX_BASE}/${DATA}/${PROJECT}"
#curl -netrc -X MKCOL "${BOX}/"
#curl -netrc --ftp-create-dirs "${BOX}/"

for f in metadata.csv ; do
	echo $f
	curl --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
done

for k in 11 16 21 31 ; do
	BOX="${BOX_BASE}/${DATA}/${PROJECT}/${k}"
	#curl -netrc -X MKCOL "${BOX}/"
	#curl -netrc --ftp-create-dirs "${BOX}/"
	#curl --silent --ftp-create-dirs -netrc -T out/${k}/kmer_matrix.tsv.gz "${BOX}/"

	for s in 14a 14b 14c ; do

		for t in TumorControl PrimaryRecurrent PrimaryRecurrentControl ; do
			BOX="${BOX_BASE}/${DATA}/${PROJECT}/${t}/${k}/${s}"
			#curl -netrc -X MKCOL "${BOX}/"
			#curl -netrc --ftp-create-dirs "${BOX}/"
	
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
				curl --silent --ftp-create-dirs -netrc -T out/${t}/${k}/${s}/${f} "${BOX}/"
			done
			for f in out/${t}/${k}/${s}/output_models/*.predictions.tsv ; do
				echo $f
				curl --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
			done
		done	#	t
	done	#	s
done	#	k

echo "Upload Complete"

