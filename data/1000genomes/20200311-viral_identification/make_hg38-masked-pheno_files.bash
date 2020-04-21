#!/usr/bin/env bash

dir="bowtie2.hg38-masked-viruses"

for v in NC_000898 NC_001348 NC_001664 NC_001716 NC_007605 NC_009333 NC_009334 ; do
for a in e2e loc ; do
	filename=${v}_${a}

#while read s; do
##	s="10335 Human alphaherpesvirus 3"
#
#	echo "${s}"
#	filename=$( echo ${s} | sed 's/ /_/g' )
#

for f in s3/1000genomes/phase3/data/*/alignment/*.hg38.unmapped.${v}.masked.loc-masked.bowtie2-${a}.bam ; do

##for f in s3/1000genomes/phase3/data/*/alignment/*.unmapped.*.diamond.viral.summary.sum-species.txt.gz ; do
#for f in s3/1000genomes/phase3/data/*/alignment/*.unmapped.*.blastn.viral.masked.summary.sum-species.txt.gz ; do

	subject=$(basename ${f})
	subject=${subject%%.*}



	#c=$( zcat ${f} | awk -F"\t" -v s="${s}" '( $2 == s ){print $1}' )
	c=$( samtools view -c ${f} )





	[ -z $c ] && c=0

	pop=$( awk -F, -v s=$subject '( $1 == s ){print $3}' /francislab/data1/raw/1000genomes/20130606_sample_info\ -\ Sample\ Info.csv )
	#echo $pop

	spop=$( awk -F"\t" -v p=${pop} '( $2 == p ){print $3}' /francislab/data1/raw/1000genomes/20131219.populations.tsv )
	#echo $spop

	echo "${v} ${a} ${spop} ${pop} ${subject} ${c}"

	for i in 1 3 10 ; do
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

#done < species.txt
#
#
#
##	check the results
##
##	for f in blastn.viral.masked/pheno_files_?/eur/* ; do echo $f ; cat $f | awk '{print $3}' | sort | uniq -c ; done


done	#	for a in e2e loc ; do
done	#	for v in NC_000898 NC_001348 NC_001664 NC_001716 NC_007605 NC_009333 NC_009334 ; do

