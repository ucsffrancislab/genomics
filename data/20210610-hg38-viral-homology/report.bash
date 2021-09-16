#!/usr/bin/env bash


accessions=$( ls -1 raw/*fasta | xargs -I% basename % .fasta )

splits="vsl c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12"
sizes="25" # "25 50 75 100"


echo -n "| accession | description | length | masked Ns | masked Ns % |"
for size in ${sizes}; do
for split in ${splits} ; do
echo -n " ${split}-${size} Ns |"
echo -n " ${split}-${size} Ns % |"
echo -n " masked ${split}-${size} Ns |"
echo -n " masked ${split}-${size} Ns % |"
done ; done
echo

echo -n "| --- | --- | --- | --- | --- |"
for size in ${sizes}; do
for split in ${splits} ; do
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
echo -n " --- |"
done ; done
echo

for a in ${accessions} ; do
	echo -n "| ${a} |"
	d=$( head -1 raw/${a}.fasta | sed -e 's/^\S*\s//' -e 's/,/ /g' )
	echo -n " ${d} |"
	l=$( tail -n +2 raw/${a}.fasta | tr -d "\n" | wc -c )
	echo -n " ${l} |"

	if [ -f masks/${a}.masked.fasta.base_count.txt ] ; then
		n=$( awk '($2=="N"){print $1}' masks/${a}.masked.fasta.base_count.txt )
	else
		n=0
	fi
	echo -n " ${n} |"

	p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
	echo -n " ${p} |"


	for size in ${sizes}; do
	for split in ${splits} ; do

		n=''
		if [ -f split.${split}/${a}.split.${size}.fasta.base_count.txt ] ; then
			n=$( awk '($2=="N"){print $1}' split.${split}/${a}.split.${size}.fasta.base_count.txt )
		fi
		if [ -z "${n}" ] ; then
			n=0
		fi
		echo -n " ${n} |"
		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
		echo -n " ${p} |"

		n=''
		if [ -f split.${split}/${a}.masked.split.${size}.fasta.base_count.txt ] ; then
			n=$( awk '($2=="N"){print $1}' split.${split}/${a}.masked.split.${size}.fasta.base_count.txt )
		fi
		if [ -z "${n}" ] ; then
			n=0
		fi
		echo -n " ${n} |"
		p=$( echo "scale=2; 100 * ${n} / ${l}" | bc -l 2> /dev/null )
		echo -n " ${p} |"

	done ; done

	echo
done



