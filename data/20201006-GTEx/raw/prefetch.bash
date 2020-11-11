#!/usr/bin/env bash


basedir="/francislab/data1/raw/20201006-GTEx"
cd ${basedir}/data

while read -r accession ; do

	echo ${accession}

#	if [ -e ${accession}/${accession}*sra ] ; then
#		echo "SRA exists. Skipping"
#	else
		echo "Downloading ${accession}"
		prefetch --progress --resume yes --max-size 1000G \
			--type sra --ngc ${basedir}/prj_20942_D10852.ngc \
			${accession}
			#--output-directory data/ ${accession}
#	fi

#	Note that prefetch will put the requested sra file in the "output-directory", 
#	it will put the dependency data in the current directory. 
#	I found it best to be in the desired output-directory and not specify.
#	This way both the desired data and its dependenies are together.
#	Sadly many files have the same dependencies resulting in a lot 
#	of redundant dependency data.

done < ${basedir}/PairedBrainRNASRAAccessions.txt

