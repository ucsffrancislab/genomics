#!/usr/bin/env bash


while read -r accession ; do

	echo ${accession}

	if [ -e data/${accession}/${accession}*sra ] ; then
		echo "SRA exists. Skipping"
	else
		echo "Downloading ${accession}"
		prefetch --progress --resume yes --max-size 1000G \
			--type sra --ngc prj_20942_D10852.ngc \
			--output-directory data/ ${accession}
	fi

done < PairedBrainRNASRAAccessions.txt

