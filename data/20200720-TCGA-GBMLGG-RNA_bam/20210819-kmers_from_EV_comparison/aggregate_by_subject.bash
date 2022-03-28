#!/usr/bin/env bash

date=$( date "+%Y%m%d%H%M%S" )

sbatch="sbatch --mail-user=$(tail -1 ~/.forward) --mail-type=FAIL "

threads=2
mem=15G

OUT=${PWD}/out
#mkdir -p ${OUT}

k=25

raw_file="subject_raw_counts.csv"
normal_file="subject_normal_counts.csv"


echo -n "subject,base_count,read_count,ave_read_length" > ${raw_file}
echo -n "subject,base_count,read_count,ave_read_length" > ${normal_file}
for kmer in $( cat kmers.all.txt ) ; do
	echo -n ",${kmer}" >> ${raw_file}
	echo -n ",${kmer}" >> ${normal_file}
done
echo >> ${raw_file}
echo >> ${normal_file}


for f in ${OUT}/??-????_R1.kmers.all.fastq.gz ; do
	#echo $f
	base=$( basename ${f} .kmers.all.fastq.gz )
	subject=${base%_R?}

	b1_count=$( cat ${OUT}/${subject}_R1.25.base_count.txt )
	b2_count=$( cat ${OUT}/${subject}_R2.25.base_count.txt )
	base_count=$((b1_count+b2_count))

	r1_count=$( cat ${OUT}/${subject}_R1.25.read_count.txt )
	r2_count=$( cat ${OUT}/${subject}_R2.25.read_count.txt )
	read_count=$((r1_count+r2_count))

	read_length=$(( base_count / read_count ))

	echo -n ${subject},${base_count},${read_count},${read_length} >> ${raw_file}
	echo -n ${subject},${base_count},${read_count},${read_length} >> ${normal_file}

	#ah yeah it should be Tj = (sum of read lengths of reads >=K) + (1-K)*(number reads >=K)
	#	normalized count = raw count * rescaling factor / total count of kmers
	#	normalized count = raw count * 1e9 / ( base_count + ((1-k)*(read_count))

	for kmer in $( cat kmers.all.txt ) ; do
		c1=$( cat ${OUT}/${subject}_R1.${kmer}.txt )
		c2=$( cat ${OUT}/${subject}_R2.${kmer}.txt )
		count=$((c1+c2))
		ncount=$( echo "scale=2; ${count} * 1000000000 / ( ${base_count} + ( ( 1 - ${k} ) * ${read_count} ) )" | bc )
		echo -n ,${count} >> ${raw_file}
		echo -n ,${ncount} >> ${normal_file}
	done
	echo >> ${raw_file}
	echo >> ${normal_file}

done


