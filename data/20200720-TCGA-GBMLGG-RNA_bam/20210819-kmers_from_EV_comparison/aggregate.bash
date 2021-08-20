#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

sbatch="sbatch --mail-user=George.Wendt@ucsf.edu --mail-type=FAIL "

threads=2
mem=15G

OUT=${PWD}/out
#mkdir -p ${OUT}

k=25


echo -n "sample,subject,base_count,read_count,ave_read_length" > raw_counts.csv
echo -n "sample,subject,base_count,read_count,ave_read_length" > normal_counts.csv
for kmer in $( cat kmers.all.txt ) ; do
	echo -n ",${kmer}" >> raw_counts.csv
	echo -n ",${kmer}" >> normal_counts.csv
done
echo >> raw_counts.csv
echo >> normal_counts.csv


for f in ${OUT}/??-????_R?.kmers.all.fastq.gz ; do
	#echo $f
	base=$( basename ${f} .kmers.all.fastq.gz )
	subject=${base%_R?}
	base_count=$( cat ${OUT}/${base}.25.base_count.txt )
	read_count=$( cat ${OUT}/${base}.25.read_count.txt )
	read_length=$(( base_count / read_count ))

	echo -n ${base},${subject},${base_count},${read_count},${read_length} >> raw_counts.csv
	echo -n ${base},${subject},${base_count},${read_count},${read_length} >> normal_counts.csv

	#ah yeah it should be Tj = (sum of read lengths of reads >=K) + (1-K)*(number reads >=K)
	#	normalized count = raw count * rescaling factor / total count of kmers
	#	normalized count = raw count * 1e9 / ( base_count + ((1-k)*(read_count))

	for kmer in $( cat kmers.all.txt ) ; do
		count=$( cat ${OUT}/${base}.${kmer}.txt )
		ncount=$( echo "scale=2; ${count} * 1000000000 / ( ${base_count} + ( ( 1 - ${k} ) * ${read_count} ) )" | bc )
		echo -n ,${count} >> raw_counts.csv
		echo -n ,${ncount} >> normal_counts.csv
	done
	echo >> raw_counts.csv
	echo >> normal_counts.csv

done


