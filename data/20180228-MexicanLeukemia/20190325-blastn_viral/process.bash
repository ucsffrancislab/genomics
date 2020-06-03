#!/usr/bin/env bash

#	ls /raid/data/raw/MexicanLeukemia/*fastq.gz | parallel --no-notice --joblog ./parallel.joblog -j20 ./process.bash &



set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail


if [ $# -ne 1 ] ; then
	echo "No file given"
fi

base=$( basename $1 _001.fastq.gz )

fastq_count=${base}.fastq_count
if [ -f ${fastq_count} ] && [ ! -w ${fastq_count} ]  ; then
	echo "${fastq_count} already exists, so skipping." >> ${base}.log
else
	echo "Creating ${fastq_count}" >> ${base}.log
	#fastq_line_count=$( wc -l <( zcat $1 ) )	#	Don't do it this way
	fastq_line_count=$( zcat $1 | wc -l )
	echo "${fastq_line_count}/4" | bc > ${fastq_count}
	chmod a-w ${fastq_count}
fi

#fasta=${base}.fasta
#if [ -f ${fasta} ] && [ ! -w ${fasta} ]  ; then
#	echo "${fasta} already exists, so skipping." >> ${base}.log
#else
#	echo "Creating ${fasta}" >> ${base}.log
#	#fastqToFa <( zcat $1 ) ${fasta} #	doesn't work
#	#	says stuff like ...
#	#	ERROR: expecting quality scores, got nothing at line 32 of /raid/data/raw/gEUVADIS/HG00096.1.M_111124_6_1.fastq.gz
#	#	paste - - - - takes 4 lines from STDIN, merges them separated by tabs
#	#	cut -f 1,2 takes the first 2 "fields" separated by tabs
#	#	sed changes the leading @ sign to a >
#	#	tr transforms the only tab to a newline
#	zcat $1 | paste - - - - | cut -f 1,2 | sed 's/^@/>/' | tr "\t" "\n" > ${fasta}
#	chmod a-w ${fasta}
#fi
#
#fasta_count=${base}.fasta_count
#if [ -f ${fasta_count} ] && [ ! -w ${fasta_count} ]  ; then
#	echo "${fasta_count} already exists, so skipping." >> ${base}.log
#else
#	echo "Creating ${fasta_count}" >> ${base}.log
#	grep -c "^>" ${fasta} > ${fasta_count}
#	chmod a-w ${fasta_count}
#fi

blast_out="${base}.viral.masked.txt"
blast_err="${base}.viral.masked.err"
if [ -f ${blast_out}.gz ] && [ ! -w ${blast_out}.gz ]  ; then
	echo "${blast_out}.gz already exists, so skipping." >> ${base}.log
else

	if [ -f ${blast_out} ] && [ ! -w ${blast_out} ]  ; then
		echo "${blast_out} already exists, so skipping." >> ${base}.log
	else
		echo "Blasting $1 creating ${blast_out}" >> ${base}.log
		zcat $1 | paste - - - - | cut -f 1,2 | sed 's/^@/>/' | tr "\t" "\n" | blastn -outfmt 6 -db viral.masked -out ${blast_out} 2> ${blast_err}
		#chmod a-w ${blast_out}
		chmod a-w ${blast_err}
	fi

	echo "gzipping ${blast_out}" >> ${base}.log
	gzip --best --force ${blast_out}
	chmod a-w ${blast_out}.gz
fi

#	blast_err_count="${base}.viral.masked.err.count"
#	if [ -f ${blast_err_count} ] && [ ! -w ${blast_err_count} ]  ; then
#		echo "${blast_err_count} already exists, so skipping." >> ${base}.log
#	else
#		echo "Counting ${blast_err}" >> ${base}.log
#		wc -l ${blast_err} > ${blast_err_count}
#		chmod a-w ${blast_err_count}
#	fi

blast_out="${base}.viral.genomic.txt"
blast_err="${base}.viral.genomic.err"
if [ -f ${blast_out}.gz ] && [ ! -w ${blast_out}.gz ]  ; then
	echo "${blast_out}.gz already exists, so skipping." >> ${base}.log
else

	if [ -f ${blast_out} ] && [ ! -w ${blast_out} ]  ; then
		echo "${blast_out} already exists, so skipping." >> ${base}.log
	else
		echo "Blasting $1 creating ${blast_out}" >> ${base}.log
		zcat $1 | paste - - - - | cut -f 1,2 | sed 's/^@/>/' | tr "\t" "\n" | blastn -outfmt 6 -db viral.genomic -out ${blast_out} 2> ${blast_err}
		#chmod a-w ${blast_out}
		chmod a-w ${blast_err}
	fi

	echo "gzipping ${blast_out}" >> ${base}.log
	gzip --best --force ${blast_out}
	chmod a-w ${blast_out}.gz
fi

