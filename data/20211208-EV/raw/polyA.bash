#!/usr/bin/env bash


#for r in 1 2 ; do
#for s in A B ; do
#for l in 4 6 8 10 12 14 16 18 20 22 24 26 28 30 ; do
#A=$( printf %${l}s | tr " " "A" )
#f=$( ls SFHH009${s}*_L001_R${r}_001.fastq.gz )
#echo ${r} - ${s} - ${l} - ${A} - ${f}
##zcat $f | sed -n '2~4p' | grep -c ${A} > ${f}.${l}A_count.txt
#done ; done ; done


dir=/francislab/data1/working/20211208-EV/20211208-preprocessing/out_noumi

rawdir=/francislab/data1/raw/20211208-EV

samples="SFHH009A SFHH009B"


echo -n "|    |"
for s in ${samples} ; do
for r in 1 2 ; do
	echo -n " ${s}_R${r} |"
done ; done
echo

echo -n "| --- |"
for s in ${samples} ; do
for r in 1 2 ; do
	echo -n " --- |"
done ; done
echo

echo -n "| Raw Read Count |"
for s in ${samples} ; do
for r in 1 2 ; do
	c=$(cat ${rawdir}/${s}*_R${r}_???.fastq.gz.read_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| HG38 Aligned Count |"
for s in ${samples} ; do
for r in 1 2 ; do
	n1=$(cat ${dir}/${s}.quality.format.t1.t3.notphiX.notviral.${r}.fqgz.read_count.txt 2> /dev/null)
	n2=$(cat ${dir}/${s}.quality.format.t1.t3.notphiX.notviral.nothg38.${r}.fqgz.read_count.txt 2> /dev/null)
	c=$( echo "${n1} - ${n2}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| HG38 Aligned % |"
for s in ${samples} ; do
for r in 1 2 ; do
	n1=$(cat ${dir}/${s}.quality.format.t1.t3.notphiX.notviral.${r}.fqgz.read_count.txt 2> /dev/null)
	n2=$(cat ${dir}/${s}.quality.format.t1.t3.notphiX.notviral.nothg38.${r}.fqgz.read_count.txt 2> /dev/null)
	d=$(cat ${rawdir}/${s}*_R${r}_???.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ( ${n1} - ${n2} ) / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

for l in 4 6 8 10 12 14 16 18 20 22 24 26 28 30 ; do
echo -n "| ${l} PolyA Raw Read Count |"
for s in ${samples} ; do
for r in 1 2 ; do
	c=$(cat ${rawdir}/${s}*_R${r}_???.fastq.gz.${l}A_count.txt 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

echo -n "| ${l} PolyA % Raw |"
for s in ${samples} ; do
for r in 1 2 ; do
	n=$(cat ${rawdir}/${s}*_R${r}_???.fastq.gz.${l}A_count.txt 2> /dev/null)
	d=$(cat ${rawdir}/${s}*_R${r}_???.fastq.gz.read_count.txt 2> /dev/null)
	c=$( echo "scale=2; 100 * ${n} / ${d}" | bc -l 2> /dev/null)
	echo -n " ${c} |"
done ; done
echo

# these 2 really can't be compared as one is not a subset of the other
#	percentages very from 10 to 300%

#echo -n "| ${l} PolyA % HG38 |"
#for s in ${samples} ; do
#for r in 1 2 ; do
#	n1=$(cat ${dir}/${s}.quality.format.t1.t3.notphiX.notviral.${r}.fqgz.read_count.txt 2> /dev/null)
#	n2=$(cat ${dir}/${s}.quality.format.t1.t3.notphiX.notviral.nothg38.${r}.fqgz.read_count.txt 2> /dev/null)
#	d=$(cat ${rawdir}/${s}*_R${r}_???.fastq.gz.${l}A_count.txt 2> /dev/null)
#	c=$( echo "scale=2; 100 * ( ${n1} - ${n2} ) / ${d}" | bc -l 2> /dev/null)
#	echo -n " ${c} |"
#done ; done
#echo

done

