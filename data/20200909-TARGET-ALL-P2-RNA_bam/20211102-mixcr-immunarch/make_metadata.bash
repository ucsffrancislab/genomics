#!/usr/bin/env bash

#	head -1 /francislab/data1/raw/20200822-TARGET-RNA_fastq/clinical.project-TARGET/clinical.project-TARGET-ALL-P1.2020-08-24/clinical.tsv > clinical.tsv
#	tail -q -n +2 /francislab/data1/raw/20200822-TARGET-RNA_fastq/clinical.project-TARGET/clinical.project-TARGET-*/clinical.tsv >> clinical.tsv

meta="${PWD}/clinical.tsv"

h=$( head -1 ${meta} )

echo -e "Sample\t${h}"

#for f in data/??-??????-???-???.txt ; do
for f in data/*.txt ; do
	s=$( basename $f .txt )
	b=${s%-*}
	b=${b%-*}
	l=$( grep -m 1 "TARGET-${b}" ${meta} )
	if [ -n "${l}" ] ; then
		echo -e "$s\t$l"
	fi
done

