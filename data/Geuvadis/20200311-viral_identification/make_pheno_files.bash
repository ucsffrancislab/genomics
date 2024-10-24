#!/usr/bin/env bash

#dir="blastn.viral.masked"
dir="diamond.viral"

while read s; do
#	s="10335 Human alphaherpesvirus 3"

  echo "${s}"
	filename=$( echo ${s} | sed 's/ /_/g' )


for f in s3/www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/*.bam.diamond.viral.summary.sum-species.txt.gz ; do
#for f in s3/geuvadis-bam/*.blastn.viral.masked.summary.sum-species.txt.gz ; do
	subject=$(basename ${f})
	subject=${subject%%.*}

	echo ${subject}
	c=$( zcat ${f} | awk -F"\t" -v s="${s}" '( $2 == s ){print $1}' )
	[ -z $c ] && c=0

	pop=$( awk -F, -v s=$subject '( $1 == s ){print $3}' /francislab/data1/raw/1000genomes/20130606_sample_info\ -\ Sample\ Info.csv )
	#echo $pop

	spop=$( awk -F"\t" -v p=${pop} '( $2 == p ){print $3}' /francislab/data1/raw/1000genomes/20131219.populations.tsv )
	#echo $spop

	for i in 1 3 10 100 1000 10000 ; do
		#	past pheno files were space delimited so space delimited it is
		#	2 should be presence
		if [ $c -ge $i ] ; then
			p_or_a=2
		else
			p_or_a=1
		fi
		mkdir -p ${dir}/pheno_files_${i}/${spop,,}
		echo "${subject} ${subject} ${p_or_a}" >> ${dir}/pheno_files_${i}/${spop,,}/${filename}
	done

done

done < species.txt
