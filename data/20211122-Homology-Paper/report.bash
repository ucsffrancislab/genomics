#!/usr/bin/env bash


accessions=$( ls -1 out/raw/*fasta | xargs -I% basename % .fasta )

splits="vsl" # c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 c16 c17 c18 c19 c20"
sizes="25" # "25 50 75 100"


#echo -n "| accession | description | length | raw Ns | raw Ns % | masked Ns | masked Ns % |"
echo -n "| accession | description | length | masked Ns | masked Ns % |"
for size in ${sizes}; do
for split in ${splits} ; do
echo -n " ${split}-${size} Ns |"
echo -n " ${split}-${size} Ns % |"
echo -n " masked ${split}-${size} Ns |"
echo -n " masked ${split}-${size} Ns % |"
echo -n " RM ${split}-${size} missed Ns |"
echo -n " RM ${split}-${size} missed Ns % |"

#echo -n " bb${split}-${size} Ns |"
#echo -n " bb${split}-${size} Ns % |"
#echo -n " masked bb${split}-${size} Ns |"
#echo -n " masked bb${split}-${size} Ns % |"

done ; done
echo

#echo -n "| --- | --- | --- | --- | --- | --- | --- |"
echo -n "| --- | --- | --- | --- | --- |"
for size in ${sizes}; do
for split in ${splits} ; do
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
#echo -n " --- |"
#echo -n " --- |"
#echo -n " --- |"
#echo -n " --- |"
done ; done
echo

for a in ${accessions} ; do
	echo -n "| ${a} |"

	d=$( head -1 out/raw/${a}.fasta | sed -e 's/^\S*\s//' -e 's/,/ /g' )
	echo -n " ${d} |"
	l=$( tail -n +2 out/raw/${a}.fasta | tr -d "\n" | wc -c )
	echo -n " ${l} |"

	if [ -f out/raw/${a}.masked.fasta.base_count.txt ] ; then
		n=$( awk '($2=="N"){print $1}' out/raw/${a}.masked.fasta.base_count.txt )
	else
		n=0
	fi
	#echo -n " ${n} |"
	#p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
	#echo -n " ${p} |"

	
	if [ -f out/masks/${a}.masked.fasta.base_count.txt ] ; then
		n=$( awk '($2=="N"){print $1}' out/masks/${a}.masked.fasta.base_count.txt )
	else
		n=0
	fi
	echo -n " ${n} |"
	p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
	echo -n " ${p} |"


	for size in ${sizes}; do
	for split in ${splits} ; do

		n=''
		if [ -f out/split.${split}/${a}.split.${size}.mask.fasta.base_count.txt ] ; then
			n=$( awk '($2=="N"){print $1}' out/split.${split}/${a}.split.${size}.mask.fasta.base_count.txt )
		fi
		if [ -z "${n}" ] ; then
			n=0
		fi
		echo -n " ${n} |"
		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
		echo -n " ${p} |"

		n=''
		if [ -f out/split.${split}/${a}.masked.split.${size}.mask.fasta.base_count.txt ] ; then
			n=$( awk '($2=="N"){print $1}' out/split.${split}/${a}.masked.split.${size}.mask.fasta.base_count.txt )
		fi
		if [ -z "${n}" ] ; then
			n=0
		fi
		echo -n " ${n} |"
		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
		echo -n " ${p} |"

		#	RepeatMasker "misses"
		if [ -f out/split.${split}/${a}.masked.split.${size}.mask.fasta.base_count.txt ] && [ -f out/masks/${a}.masked.fasta.base_count.txt ] ; then
			mmn=$( awk '($2=="N"){print $1}' out/split.${split}/${a}.masked.split.${size}.mask.fasta.base_count.txt )
			rmn=$( awk '($2=="N"){print $1}' out/masks/${a}.masked.fasta.base_count.txt )
			n=$( echo "${mmn} - ${rmn}" | bc -l 2> /dev/null )
		else
			n=0
		fi
		echo -n " ${n} |"
		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
		echo -n " ${p} |"





#		n=''
#		if [ -f out/bbmasked/${a}.${size}.fasta.base_count.txt ] ; then
#			n=$( awk '($2=="N"){print $1}' out/bbmasked/${a}.${size}.fasta.base_count.txt )
#		fi
#		if [ -z "${n}" ] ; then
#			n=0
#		fi
#		echo -n " ${n} |"
#		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
#		echo -n " ${p} |"
#
#		n=''
#		if [ -f out/bbmasked/${a}.masked.${size}.fasta.base_count.txt ] ; then
#			n=$( awk '($2=="N"){print $1}' out/bbmasked/${a}.masked.${size}.fasta.base_count.txt )
#		fi
#		if [ -z "${n}" ] ; then
#			n=0
#		fi
#		echo -n " ${n} |"
#		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
#		echo -n " ${p} |"





	done ; done

	echo
done



