#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


data_source="USC-CHLA-NBL"
molecule="RNA"

for database in viral.masked viral.genomic ; do

	outfile="${data_source}.${database}.csv"

	echo -e "source\tmolecule\tsample\tsubject\tread_count\tblast_err_count\tqaccver\tsaccver\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore" > ${outfile}

	for f in *.${database}.txt.gz ; do
		base=$(basename $f .${database}.txt.gz )
		subject=${base%%.*}
		fastq_count=$( cat ${base}.fastq_count )
		blast_err_count=$( cat ${base}.${database}.err | wc -l )
		zcat $f | sed "s/^/${data_source}\t${molecule}\t${base}\t${subject}\t${fastq_count}\t${blast_err_count}\t/"
	done >> ${outfile}

	#gzip ${outfile}

done

