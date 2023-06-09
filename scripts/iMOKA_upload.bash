#!/usr/bin/env bash


#set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
#set -o pipefail
#set -x  #       print expanded command before executing it


BOX_BASE="ftps://ftp.box.com/Francis _Lab_Share"
PROJECT=$( basename ${PWD} )
DATA=$( basename $( dirname ${PWD} ) )
#BOX="${BOX_BASE}/${DATA}/${PROJECT}"


#	/francislab/data1/working/20210428-EV/20230606-iMOKA/out/GBM-Lexogen-16/
basedir=$1

echo "Processing $1"

BOX="${BOX_BASE}/${DATA}/${PROJECT}/$( basename $1 )"

#	create_matrix.tsv - input samples used
#	output_fi.tsv - combination of kmers and rankings
#	aggregated.json - for the iMOKA desktop app
#	output.json - for the iMOKA desktop app
#	*_RF.predictions.tsv - model predictions

#	reduced.matrix_stable.tsv
#	output_predictions.tsv


#	select_kmers.txt - kmers used by all of the models from the random forest models
#	predict_matrix.tsv - samples not used for models
#	topredict.tsv - select kmer counts of unused samples
#	matrix.tsv - select kmer counts of input samples
cd $basedir

for f in reduced.matrix create_matrix.tsv aggregated.json output.json output_fi.tsv reduced.matrix_stable.tsv \
		output_predictions.tsv select_kmers.txt predict_matrix.tsv topredict.tsv matrix.tsv ; do
	if [ -f ${f} ] ; then
		echo "Uploading ${f}."
		curl --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
	else
		echo "${f} is not present."
	fi
done

#for f in ${basedir}/output_models/*.predictions.tsv ; do
#	echo $f
#	curl --silent --ftp-create-dirs -netrc -T ${f} "${BOX}/"
#done

