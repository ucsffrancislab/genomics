#!/usr/bin/env bash

#set -e	#	exit if any command fails
#set -u	#	Error on usage of unset variables
#set -o pipefail
#set -x

basedir="/francislab/data1/raw/20201006-GTEx"
cd ${basedir}/data

while read -r accession ; do

	echo ${accession}

	#if [ -e ${accession}/${accession}*sra ] ; then
	if [ -d ${accession} ] && [ ! -w ${accession} ] ; then
		echo "Write-protected SRA exists. Skipping"
	else
		echo "Prefetching ${accession}"
		prefetch --progress --resume yes --max-size 1000G \
			--type sra --ngc ${basedir}/prj_20942_D10852.ngc \
			${accession}
			#--output-directory data/ ${accession}

#	Too often prefetch fails. Rerunning and it eventually works?
#	Trying to handle
#	2020-11-12T15:03:25 prefetch.2.10.8 int: empty while validating file within network system module - cannot open remote file: https://gap-download.be-md.ncbi.nlm.nih.gov/sragap/D0B7CACB-2DA5-4529-A2D9-7A184912A118/SRR1325665?pId=20942
#	2020-11-12T15:03:27 prefetch.2.10.8: 1) Downloading 'SRR1325665'...
#	2020-11-12T15:03:27 prefetch.2.10.8:  Downloading via HTTPS...
#	2020-11-12T15:03:32 prefetch.2.10.8 int: self NULL while reading file within network system module - Cannot KStreamRead: /francislab/data1/raw/20201006-GTEx/SRR1325665/SRR1325665_dbGaP-20942.sra

		status=$?
		echo "Prefetch return status:${status}:"
		if [ ${status} -eq 0 ] ; then
			echo "Write protecting ${accession}"
			chmod -w ${accession}
		else
			echo "Prefetching ${accession} failed. Rerun."
		fi
	fi

#	Note that prefetch will put the requested sra file in the "output-directory", 
#	it will put the dependency data in the current directory. 
#	I found it best to be in the desired output-directory and not specify.
#	This way both the desired data and its dependenies are together.
#	Sadly many files have the same dependencies resulting in a lot 
#	of redundant dependency data.

done < ${basedir}/PairedBrainRNASRAAccessions.txt

