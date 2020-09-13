#!/usr/bin/env bash


set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

mkdir -p subject/

ls -1 out/*R?.fastq.gz | awk -F/ '{print $2}' | awk -F- '{print $1"-"$2}' | uniq | while read -r subject ; do
	echo $subject
	for r in R1 R2 ; do
		files=( $( \ls -1 out/${subject}*${r}.fastq.gz ) )
		file_count=${#files[@]}

		if [ -f "subject/${subject}_${r}.fastq.gz" ] ; then
			echo "Skipping"
			echo "subject/${subject}_${r}.fastq.gz exists"
		else
			if [ $file_count -eq 1 ] ; then
				echo "Linking"
				echo "ln -s ${files[0]} subject/${subject}_${r}.fastq.gz"
				ln -s ../${files[0]} subject/${subject}_${r}.fastq.gz
			else
				echo "Concatting"
				echo "cat ${files[@]} > subject/${subject}_${r}.fastq.gz"
				cat ${files[@]} > subject/${subject}_${r}.fastq.gz
			fi
		fi

	done
done


