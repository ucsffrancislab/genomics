#!/usr/bin/env bash



for s in out/???.hkle ; do
	echo $s
	b=$( basename $s .hkle )
	echo $b
	os=${s}.insertion_points
	mkdir ${os}

	for f in /francislab/data1/refs/bowtie2/SVAs_and_HERVs_KWHE/*.rev.1.bt2 ; do
		f=$( basename ${f} .rev.1.bt2 )
		echo $f

		for q in Q00 Q10 Q20 ; do
			echo $q

			for p in paired unpaired ; do
				echo $p

				cat ${s}/${b}.bowtie2.${f}.very_sensitive_local.${p}.aligned.*.bowtie2.hg38.${q}.*insertion_points \
					| sort | uniq -c > ${os}/${b}.${f}.${p}.${q}.insertions_point_counts.1.txt

				cat ${s}/${b}.bowtie2.${f}.very_sensitive_local.${p}.aligned.*.bowtie2.hg38.${q}.*insertion_points \
					| awk '{sub(".$","0");print}' | sort | uniq -c > ${os}/${b}.${f}.${p}.${q}.insertions_point_counts.10.txt

				cat ${s}/${b}.bowtie2.${f}.very_sensitive_local.${p}.aligned.*.bowtie2.hg38.${q}.*insertion_points \
					| awk '{sub("..$","00");print}' | sort | uniq -c > ${os}/${b}.${f}.${p}.${q}.insertions_point_counts.100.txt

				cat ${s}/${b}.bowtie2.${f}.very_sensitive_local.${p}.aligned.*.bowtie2.hg38.${q}.*insertion_points \
					| awk '{sub("...$","000");print}' | sort | uniq -c > ${os}/${b}.${f}.${p}.${q}.insertions_point_counts.1000.txt

			done

		done

	done

done


