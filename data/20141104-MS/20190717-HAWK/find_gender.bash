#!/usr/bin/env bash

#	Sadly, these appear to be only unmapped RNA reads, so there are no reads that align to chrX or chrY.


for bam in /raid/data/raw/MS/*.bam ; do
	base=$( basename ${bam} .bam )
	echo ${base}
	for q in 40 60 ; do
		for chr in X Y ; do
			echo ${chr}

			f=${base}.${chr}.${q}.count.txt	
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				echo "Creating $f"
				samtools view -c -q ${q} -@ 39 ${bam} chr${chr} > ${f}
				chmod a-w $f
			fi

		done

		f=${base}.XY.${q}.ratio.txt
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			echo "Creating $f"
			X=$( cat ${base}.X.${q}.count.txt )
			Y=$( cat ${base}.Y.${q}.count.txt )
			echo "${X} / ${Y}" | bc -l > ${f}
			chmod a-w $f
		fi

	done
done


