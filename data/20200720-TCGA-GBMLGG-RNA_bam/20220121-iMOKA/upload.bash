#!/usr/bin/env bash

BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20220121-iMOKA"
curl -netrc -X MKCOL "${BOX}/"

for f in metadata.cart.TCGA.GBM-LGG.WGS.bam.2020-07-17.csv TCGA.Glioma.metadata.tsv ; do
	echo $f
	curl -netrc -T ${f} "${BOX}/"
done

for k in 11 21 31 ; do
	for s in 80a 80b 80c ; do
		BOX="https://dav.box.com/dav/Francis _Lab_Share/20200720-TCGA-GBMLGG-RNA_bam/20220121-iMOKA/IDH.${k}.${s}"
		curl -netrc -X MKCOL "${BOX}/"

		curl -netrc -T ${k}.${s}.mers.txt "${BOX}/"
		curl -netrc -T ${k}.${s}.raw.merged.csv.gz "${BOX}/"
		curl -netrc -T ${k}.${s}.scaled.merged.csv.gz "${BOX}/"

		for f in create_matrix.tsv aggregated.json output.json output_fi.tsv select_kmers.txt predict_matrix.tsv topredict.tsv ; do
			echo $f
			curl -netrc -T IDH.${k}.${s}/${f} "${BOX}/"

			for f in IDH.${k}.${s}/output_models/*.predictions.tsv ; do
				echo $f
				curl -netrc -T ${f} "${BOX}/"
			done
		done
	done
done

