#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

set -x


while [ $# -gt 0 ] ; do
	case $1 in
		-i|--i*)
			shift; file=$1; shift;;
		-t|--t*)
			shift; threads=$1; shift ;;
		-c|--c*)
			shift; canonical='--both-strands';;		#	in jellyfish 2, this is --canonical
		-k|--k*)
			shift; kmersize=$1; shift ;;
		*)
			shift;;
	esac
done


unique_extension=".fastq.gz"

INDIR=$( dirname $file )
OUTPREFIX=$( basename $file	${unique_extension} )
OUTDIR="${INDIR}/${OUTPREFIX}_kmers"

f=${OUTDIR}_jellyfish
if [ -f $f ] && [ ! -w $f ] ; then
	echo "Write-protected $f exists. Skipping."
else
	echo "Creating $f"

	mkdir -p ${OUTDIR}


	#	I think that perhaps this samtools fastq should have some flags added to filter out only high quality, proper pair aligned reads?
	#	Sadly "samtools fastq" does not have a -q quality filter as does "samtools view". Why not?
	#	I suppose that I could pipe one to the other like ...
	#		<( samtools view -h -q 40 -f 2 ${file} | samtools fastq - )

	#	I think that when extracting reads from a bam, we probably shouldn't use the -C(canonical) flag,
	#		particularly when select high quality mappings

	date
	#	--matrix ${f}.Matrix 
	hawk_jellyfish count ${canonical} --output ${OUTDIR}/tmp \
		--mer-len ${kmersize} --threads ${threads} --size 5G \
		--timing ${f}.Timing --stats ${f}.Stats \
		<( zcat ${file} )
	date

	COUNT=$(ls ${OUTDIR}/tmp* |wc -l)

	if [ $COUNT -eq 1 ]
	then
		mv ${OUTDIR}/tmp_0 ${f}
	else
		hawk_jellyfish merge -o ${f} ${OUTDIR}/tmp*
	fi
	rm -rf ${OUTDIR}

	chmod a-w $f
fi
