#!/usr/bin/env bash

one=/francislab/data1/working/20230628-Costello/20231005-STAR/out
two=/francislab/data1/working/20230628-Costello/20231016-STAR_two_pass/out

samples=$( ls -1 out/*.Log.final.out | xargs -I% basename % .Log.final.out )

echo -n "Sample"
for sample in ${samples} ; do
	echo -n ,${sample}
done
echo

echo -n "Number of input reads"
for sample in ${samples} ; do
	value=$( grep "Number of input reads" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

#echo -n "Number of input reads"
#for sample in ${samples} ; do
#	value=$( grep "Number of input reads" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
#	echo -n ,${value}
#done
#echo

echo -n "1 Uniquely mapped reads number"
for sample in ${samples} ; do
	value=$( grep "Uniquely mapped reads number" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "2 Uniquely mapped reads number"
for sample in ${samples} ; do
	value=$( grep "Uniquely mapped reads number" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "Uniquely mapped reads number change 2-1"
for sample in ${samples} ; do
	onepass=$( grep "Uniquely mapped reads number" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	twopass=$( grep "Uniquely mapped reads number" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	#value=$( echo "scale=2; ${twopass} - ${onepass}" | bc -l 2> /dev/null )
	value=$( echo "${twopass} - ${onepass}" | bc -l 2> /dev/null )
	echo -n ,${value}
done
echo

echo -n "Uniquely mapped reads number change 2-1%"
for sample in ${samples} ; do
	onepass=$( grep "Uniquely mapped reads number" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	twopass=$( grep "Uniquely mapped reads number" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	#value=$( echo "scale=2; ${twopass} - ${onepass}" | bc -l 2> /dev/null )
	value=$( echo "scale=2; 100 * ( ${twopass} - ${onepass} ) / ${onepass}" | bc -l 2> /dev/null )
	echo -n ,${value}
done
echo


#echo -n "Number of reads unmapped: too many mismatches"
#for sample in ${samples} ; do
#	value=$( grep "Number of reads unmapped: too many mismatches" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
#	echo -n ,${value}
#done
#echo
#
#echo -n "Number of reads unmapped: too many mismatches"
#for sample in ${samples} ; do
#	value=$( grep "Number of reads unmapped: too many mismatches" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
#	echo -n ,${value}
#done
#echo
#
#echo -n "Number of reads unmapped: too many mismatches change 2-1"
#for sample in ${samples} ; do
#	onepass=$( grep "Number of reads unmapped: too many mismatches" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
#	twopass=$( grep "Number of reads unmapped: too many mismatches" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
#	#value=$( echo "scale=2; ${twopass} - ${onepass}" | bc -l 2> /dev/null )
#	value=$( echo "${twopass} - ${onepass}" | bc -l 2> /dev/null )
#	echo -n ,${value}
#done
#echo


echo -n "1 Number of reads unmapped: too short"
for sample in ${samples} ; do
	value=$( grep "Number of reads unmapped: too short" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "2 Number of reads unmapped: too short"
for sample in ${samples} ; do
	value=$( grep "Number of reads unmapped: too short" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "Number of reads unmapped: too short change 2-1"
for sample in ${samples} ; do
	onepass=$( grep "Number of reads unmapped: too short" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	twopass=$( grep "Number of reads unmapped: too short" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	#value=$( echo "scale=2; ${twopass} - ${onepass}" | bc -l 2> /dev/null )
	value=$( echo "${twopass} - ${onepass}" | bc -l 2> /dev/null )
	echo -n ,${value}
done
echo


echo -n "1 Number of reads unmapped: other"
for sample in ${samples} ; do
	value=$( grep "Number of reads unmapped: other" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "2 Number of reads unmapped: other"
for sample in ${samples} ; do
	value=$( grep "Number of reads unmapped: other" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "Number of reads unmapped: other change 2-1"
for sample in ${samples} ; do
	onepass=$( grep "Number of reads unmapped: other" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	twopass=$( grep "Number of reads unmapped: other" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	#value=$( echo "scale=2; ${twopass} - ${onepass}" | bc -l 2> /dev/null )
	value=$( echo "${twopass} - ${onepass}" | bc -l 2> /dev/null )
	echo -n ,${value}
done
echo

echo -n "1 Number of reads mapped to multiple loci"
for sample in ${samples} ; do
	value=$( grep "Number of reads mapped to multiple loci" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "2 Number of reads mapped to multiple loci"
for sample in ${samples} ; do
	value=$( grep "Number of reads mapped to multiple loci" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "Number of reads mapped to multiple loci change 2-1"
for sample in ${samples} ; do
	onepass=$( grep "Number of reads mapped to multiple loci" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	twopass=$( grep "Number of reads mapped to multiple loci" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	#value=$( echo "scale=2; ${twopass} - ${onepass}" | bc -l 2> /dev/null )
	value=$( echo "${twopass} - ${onepass}" | bc -l 2> /dev/null )
	echo -n ,${value}
done
echo

echo -n "1 Number of reads mapped to too many loci"
for sample in ${samples} ; do
	value=$( grep "Number of reads mapped to too many loci" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "2 Number of reads mapped to too many loci"
for sample in ${samples} ; do
	value=$( grep "Number of reads mapped to too many loci" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	echo -n ,${value}
done
echo

echo -n "Number of reads mapped to too many loci change 2-1"
for sample in ${samples} ; do
	onepass=$( grep "Number of reads mapped to too many loci" ${one}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	twopass=$( grep "Number of reads mapped to too many loci" ${two}/${sample}.Log.final.out | awk -F\| '{print $2}' )
	#value=$( echo "scale=2; ${twopass} - ${onepass}" | bc -l 2> /dev/null )
	value=$( echo "${twopass} - ${onepass}" | bc -l 2> /dev/null )
	echo -n ,${value}
done
echo

