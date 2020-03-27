#!/usr/bin/env bash


#	2 should be presence 



while read s; do
#	s="10335 Human alphaherpesvirus 3"

  echo "${s}"
	filename=$( echo ${s} | sed 's/ /_/g' )


	
for f in s3/1000genomes/phase3/data/*/alignment/*.unmapped.*.bam.diamond.viral.summary.sum-species.txt.gz ; do
	subject=$(basename ${f})
	subject=${subject%%.*}

	echo ${subject}
	c=$( zcat ${f} | awk -F"\t" -v s="${s}" '( $2 == s ){print $1}' )
	[ -z $c ] && c=0

	pop=$( awk -F, -v s=$subject '( $1 == s ){print $3}' /francislab/data1/raw/1000genomes/20130606_sample_info\ -\ Sample\ Info.csv )
	#echo $pop

	spop=$( awk -F"\t" -v p=${pop} '( $2 == p ){print $3}' /francislab/data1/raw/1000genomes/20131219.populations.tsv )
	#echo $spop


#	#	past pheno files were space delimited so space delimited it is
#	if [ $c -ge 1 ] ; then
#		p_or_a=2
#	else
#		p_or_a=1
#	fi
#	mkdir -p pheno_files_1/${spop,,}
#	echo "${subject} ${subject} ${p_or_a}" >> pheno_files_1/${spop,,}/${filename}
#	
#	if [ $c -ge 3 ] ; then
#		p_or_a=2
#	else
#		p_or_a=1
#	fi
#	mkdir -p pheno_files_3/${spop,,}
#	echo "${subject} ${subject} ${p_or_a}" >> pheno_files_3/${spop,,}/${filename}

	if [ $c -ge 10 ] ; then
		p_or_a=2
	else
		p_or_a=1
	fi
	mkdir -p pheno_files_10/${spop,,}
	echo "${subject} ${subject} ${p_or_a}" >> pheno_files_10/${spop,,}/${filename}

	if [ $c -ge 100 ] ; then
		p_or_a=2
	else
		p_or_a=1
	fi
	mkdir -p pheno_files_100/${spop,,}
	echo "${subject} ${subject} ${p_or_a}" >> pheno_files_100/${spop,,}/${filename}

	if [ $c -ge 1000 ] ; then
		p_or_a=2
	else
		p_or_a=1
	fi
	mkdir -p pheno_files_1000/${spop,,}
	echo "${subject} ${subject} ${p_or_a}" >> pheno_files_1000/${spop,,}/${filename}

done

done < species.txt
