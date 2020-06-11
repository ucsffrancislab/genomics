#!/usr/bin/env bash



for s in out/???.hkle ; do
	echo $s
	b=$( basename $s .hkle )
	echo $b

	for f in /francislab/data1/refs/bowtie2/SVAs_and_HERVs_KWHE/*.rev.1.bt2 ; do
		f=$( basename ${f} .rev.1.bt2 )
		echo $f

		#cat ${s}/${b}.bowtie2.${f}.very_sensitive_local.unpaired.aligned.*.bowtie2.hg38.Q00.*insertion_points \
		#	| sort | uniq -c > ${s}.insertions_point_counts.txt

		#cat ${s}/${b}.bowtie2.${f}.very_sensitive_local.unpaired.aligned.*.bowtie2.hg38.Q00.*insertion_points \
		#	| awk '{sub(".$","0");print}' | sort | uniq -c > ${s}.insertions_point_counts.0.txt

		#cat ${s}/${b}.bowtie2.${f}.very_sensitive_local.unpaired.aligned.*.bowtie2.hg38.Q00.*insertion_points \
		#	| awk '{sub("..$","00");print}' | sort | uniq -c > ${s}.insertions_point_counts.00.txt

		#cat ${s}/${b}.bowtie2.${f}.very_sensitive_local.unpaired.aligned.*.bowtie2.hg38.Q00.*insertion_points \
		#	| awk '{sub("...$","000");print}' | sort | uniq -c > ${s}.insertions_point_counts.000.txt

	done

done


