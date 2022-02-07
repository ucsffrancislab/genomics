#!/usr/bin/env bash

BOX="https://dav.box.com/dav/Francis _Lab_Share/20200603-TCGA-GBMLGG-WGS"
curl -netrc -X MKCOL "${BOX}/"

BOX="https://dav.box.com/dav/Francis _Lab_Share/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA"
curl -netrc -X MKCOL "${BOX}/"

for f in metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv TCGA.Glioma.metadata.tsv ; do
	echo $f
	curl -netrc -T ${f} "${BOX}/"
done

for k in 11 21 31 ; do
	for s in 80a 80b 80c ; do
		BOX="https://dav.box.com/dav/Francis _Lab_Share/20200603-TCGA-GBMLGG-WGS/20220121-iMOKA/IDH.${k}.${s}"
		curl -netrc -X MKCOL "${BOX}/"

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
		for f in create_matrix.tsv aggregated.json output.json output_fi.tsv select_kmers.txt predict_matrix.tsv topredict.tsv matrix.tsv ; do
			echo $f
			curl -netrc -T IDH.${k}.${s}/${f} "${BOX}/"

		done
		for f in IDH.${k}.${s}/output_models/*.predictions.tsv ; do
			echo $f
			curl -netrc -T ${f} "${BOX}/"
		done
	done
done

