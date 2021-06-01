#!/usr/bin/env bash

peptide=$( basename $1 .nucleotides.gz )
#TNRTLKTQLVKQK.nucleotides.gz
fasta=${peptide}.fasta.gz

i=1
while read line ; do
	echo ">${peptide}_$((i++))"
	echo $line
done < <( zcat $1 ) | gzip > ${fasta}

