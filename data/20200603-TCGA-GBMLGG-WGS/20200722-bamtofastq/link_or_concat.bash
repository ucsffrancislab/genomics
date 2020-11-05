#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

mkdir -p sample/


#	Only the primary tumor so TCGA-??-????-01*
#	https://docs.gdc.cancer.gov/Encyclopedia/pages/TCGA_Barcode/
#	https://gdc.cancer.gov/resources-tcga-users/tcga-code-tables/
#	https://gdc.cancer.gov/resources-tcga-users/tcga-code-tables/tissue-source-site-codes
#	https://gdc.cancer.gov/resources-tcga-users/tcga-code-tables/sample-type-codes


ls -1 out/*R1.fastq.gz | awk -F/ '{print $2}' | awk -F- '{print $1"-"$2"-"$3}' | uniq | while read -r sample ; do
	echo $sample
	for r in R1 R2 ; do
		files=( $( \ls -1 out/${sample}*${r}.fastq.gz ) )
		file_count=${#files[@]}

		if [ -f "sample/${sample}_${r}.fastq.gz" ] ; then
			echo "Skipping"
			echo "sample/${sample}_${r}.fastq.gz exists"
		else
			if [ $file_count -eq 1 ] ; then
				echo "Linking"
				echo "ln -s ${files[0]} sample/${sample}_${r}.fastq.gz"
				ln -s ../${files[0]} sample/${sample}_${r}.fastq.gz
			else
				echo "Concatting"
				echo "cat ${files[@]} > sample/${sample}_${r}.fastq.gz"
				cat ${files[@]} > sample/${sample}_${r}.fastq.gz
			fi
		fi
	done
done


