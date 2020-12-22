#!/usr/bin/env bash

mkdir -p encode/json
mkdir -p encode/raw

while IFS="," read -r expid donorid type termid ; do

	if [ "${expid}" == "Experiment ID" ] ; then
		continue
	fi

	echo $expid

	mkdir -p encode/raw/${expid}

	json="encode/json/${expid}.json"

	#curl -H "Accept: application/json" "https://www.encodeproject.org/experiments/${expid}/#tables" > ${json}

	for accession in $( cat ${json} | jq -r '.files[] | select(.file_format == "fastq") | select(.biological_replicates == [2] ) | .accession' ) ; do

		echo ${accession}
		
		s3_uri=$( cat ${json} | jq -r '.files[] | select(.accession == "'${accession}'") | .s3_uri' )
		echo $s3_uri

		#aws s3 cp $s3_uri encode/raw/${expid}/

		run_type=$( cat ${json} | jq -r '.files[] | select(.accession == "'${accession}'") | .run_type' )

		flowcell=$( cat ${json} | jq -r '.files[] | select(.accession == "'${accession}'") | .flowcell_details[].flowcell' | paste -sd _ )
		lane=$( cat ${json} | jq -r '.files[] | select(.accession == "'${accession}'") | .flowcell_details[].lane' | paste -sd _ )

		if [ -n "${flowcell}" ] ; then

				paired_end=""

				echo $run_type
				if [ $run_type == "paired-ended" ] ; then
					outfile="${expid}-${flowcell}-${lane}"

					paired_end=$( cat ${json} | jq -r '.files[] | select(.accession == "'${accession}'") | .paired_end' )
					echo ${paired_end}

					outfile="${outfile}_R${paired_end}"

				else
					outfile="${expid}-${accession}"
				fi
		else
				outfile="${expid}-${accession}"
		fi

		outfile=${outfile}.fastq.gz

		echo $outfile

		echo ln -s raw/${expid}/$( basename ${s3_uri} ) encode/$outfile >> link_script

	done

	echo
	echo "---"
	echo

done < encode.csv

