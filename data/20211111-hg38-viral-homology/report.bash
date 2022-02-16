#!/usr/bin/env bash


accessions=$( ls -1 out/raw/*fasta | xargs -I% basename % .fasta )

#splits="vsl" # c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 c16 c17 c18 c19 c20"
#splits="bt2"
splits="STAR"
sizes="25" # "25 50 75 100"


echo -n "| accession | description | length | Raw Ns | Raw Ns % | RM Ns | RM Ns % |"
echo -n " HM Ns |"
echo -n " HM Ns % |"
echo -n " RM+HM Ns |"
echo -n " RM+HM Ns % |"
echo -n " RM+HM - HM Ns |"
echo -n " RM+HM - HM Ns % |"
echo

#for size in ${sizes}; do
#for split in ${splits} ; do
#echo -n " ${split}-${size} Ns |"
#echo -n " ${split}-${size} Ns % |"
#echo -n " masked ${split}-${size} Ns |"
#echo -n " masked ${split}-${size} Ns % |"
#echo -n " RM ${split}-${size} missed Ns |"
#echo -n " RM ${split}-${size} missed Ns % |"
#done ; done
#echo

echo -n "| --- | --- | --- | --- | --- | --- | --- |"
for size in ${sizes}; do
for split in ${splits} ; do
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
done ; done
echo

for a in ${accessions} ; do
	echo -n "| ${a} |"	#	accession

	d=$( head -1 out/raw/${a}.fasta | sed -e 's/^\S*\s//' -e 's/,/ /g' ) 
	echo -n " ${d} |"	# description
	l=$( tail -n +2 out/raw/${a}.fasta | tr -d "\n" | wc -c )
	echo -n " ${l} |"	#	length

	f=out/raw/${a}.fasta.base_count.txt
	if [ -f ${f} ] ; then
		n=$( awk '($2=="N"){print $1}' ${f} )
	else
		n=0
	fi
	echo -n " ${n:=0} |"
	p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
	echo -n " ${p} |"

	#f=out/masks/${a}.masked.fasta.base_count.txt
	f=out/RM/${a}.masked.fasta.base_count.txt
	if [ -f ${f} ] ; then
		n=$( awk '($2=="N"){print $1}' ${f} )
	else
		n=0
	fi
	echo -n " ${n:=0} |"
	p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
	echo -n " ${p} |"


	for size in ${sizes}; do
	for split in ${splits} ; do

		n=''
		f=out/raw.split.HM.${split}/${a}.split.${size}.mask.fasta.base_count.txt
		if [ -f ${f} ] ; then
			n=$( awk '($2=="N"){print $1}' ${f} )
		else
#		fi
#		if [ -z "${n}" ] ; then
			n=0
		fi
		echo -n " ${n:=0} |"
		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
		echo -n " ${p} |"

		n=''
		f=out/RM.split.HM.${split}/${a}.masked.split.${size}.mask.fasta.base_count.txt
		if [ -f ${f} ] ; then
			n=$( awk '($2=="N"){print $1}' ${f} )
		else
#		fi
#		if [ -z "${n}" ] ; then
			n=0
		fi
		echo -n " ${n:=0} |"
		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
		echo -n " ${p} |"

		#	RepeatMasker "misses"
		f1=out/RM.split.HM.${split}/${a}.masked.split.${size}.mask.fasta.base_count.txt
		f2=out/RM/${a}.masked.fasta.base_count.txt
		if [ -f ${f1} ] && [ -f ${f1} ] ; then
			mmn=$( awk '($2=="N"){print $1}' ${f1} )
			rmn=$( awk '($2=="N"){print $1}' ${f2} )
			n=$( echo "${mmn} - ${rmn}" | bc -l 2> /dev/null )
		else
			n=0
		fi
		echo -n " ${n:=0} |"
		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
		echo -n " ${p} |"

	done ; done

	echo
done



