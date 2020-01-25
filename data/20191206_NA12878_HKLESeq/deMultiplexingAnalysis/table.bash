#!/usr/bin/env bash


echo -n "Sample #, raw count"
#for x in 1 2 12 12rc 1rc2 1rc2rc 21 2rc1 21rc 2rc1rc ; do
for x in 1 2 12 12rc 1rc2 1rc2rc ; do
	echo -n ",deML.${x} count"
	#echo -n ",deML.${x} UNconsolidated count"
done
#for min_reads in 1 10 100 ; do
#	echo -n ",umi.${min_reads}.1 count"
#done
#for min_reads in 1 10 100 ; do
#for min_qual in 5 10 15 20 ; do
#	echo -n ",umi.${min_reads}.1.${min_qual}.0.9 count"
#	echo -n ",umi.${min_reads}.1.${min_qual}.0.9 consolidated count"
#done;done
echo -n ",UMI count"
echo


for i in $( seq -w 1 36 ) ; do

	echo -n $i
	echo -n ,$( zcat raw/${i}.R1.fastq.gz | paste - - - - | wc -l )

	#for x in 1 2 12 12rc 1rc2 1rc2rc 21 2rc1 21rc 2rc1rc ; do
	for x in 1 2 12 12rc 1rc2 1rc2rc ; do
		echo -n ,$( zcat deML.${x}/deML_${i}_r1.fq.gz | paste - - - - | wc -l )
	done

	#for min_reads in 1 10 100 ; do
	#	echo -n ,$( cat umi.${min_reads}.1/${i}.r1.fastq | paste - - - - | wc -l )
	#done
	#for min_reads in 1 10 100 ; do
	#for min_qual in 5 10 15 20 ; do
	#	echo -n ,$( cat umi.${min_reads}.1.${min_qual}.0.9/${i}.r1.fastq | paste - - - - | wc -l )
	#	echo -n ,$( cat umi.${min_reads}.1.${min_qual}.0.9/${i}.consolidated.r1.fastq | paste - - - - | wc -l )
	#done;done
	echo -n ,$( cat umi.1.1/${i}.r1.fastq | paste - - - - | wc -l )

	echo
done	#	for i in $( seq 1 36 ) ; do


#	file size 0 screws things up with zcat
#echo -n "TOTAL"
#echo -n ,$( zcat ../SFSP003_S1_L001_R1_001.fastq.gz | paste - - - - | wc -l )
#for x in 1 2 12 12rc 1rc2 1rc2rc 21 2rc1 21rc 2rc1rc ; do
#	#echo -n ,$( zcat deML.${x}/deML_*_r1*fq.gz 2>/dev/null | paste - - - - | wc -l )
#	echo -n ,$( zcat $( find deML.${x} -name deML_*_r1*fq.gz -size +0 ) | paste - - - - | wc -l )
#done
#for min_reads in 1 10 100 ; do
#	echo -n ,$( cat umi.${min_reads}.1/*.r1.fastq | paste - - - - | wc -l )
#done
#echo


