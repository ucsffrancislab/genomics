#!/usr/bin/env bash


function usage(){
	echo
	echo "Usage: (NO EQUALS SIGNS)"
	echo
	echo "$( basename $0 ) virii_list"
	echo
	exit 1
}

virii=$1
[ $# -eq 0 ] && usage



sep=","


echo -en ${sep}
bases=$( basename -a -s .nonhg38.fasta.gz *fasta.gz )	#| paste -sd ',' )
echo $bases | tr ' ' ${sep}

echo -en "nonhg38"
for b in $bases ; do
echo -en ${sep}$( cat $b.nonhg38.fasta.reads.txt )
done
echo

#for f in .nonhg38.fasta.reads.txt

#	some of the virii have trailing spaces which messes things up. Fixing.

while read virus ; do
echo -en \"$virus\"

for b in $bases ; do
echo -en ${sep}$( grep  ">${virus}\s*$" $b.nonhg38.blastn.viral_hits.txt | awk -F">" '{print int($1)}' )
done
echo

done < $virii




