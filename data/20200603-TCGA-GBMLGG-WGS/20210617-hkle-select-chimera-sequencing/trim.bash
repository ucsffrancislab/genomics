#!/usr/bin/env bash

set -e	#	exit if any command fails
set -u	#	Error on usage of unset variables
set -o pipefail

REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
KALLISTO=${REFS}/kallisto
SUBREAD=${REFS}/subread
BOWTIE2=${REFS}/bowtie2
BLASTDB=${REFS}/blastn
KRAKEN2=${REFS}/kraken2
DIAMOND=${REFS}/diamond
STAR=${REFS}/STAR
SALMON=${REFS}/salmon

INDIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20210617-hkle-select-sequencing/select"
DIR="/francislab/data1/working/20200603-TCGA-GBMLGG-WGS/20210617-hkle-select-sequencing/101"
mkdir -p ${DIR}

#	remember 64 cores and ~504GB mem
#threads=16
#vmem=125
#threads=8
#vmem=62
threads=4
vmem=30

date=$( date "+%Y%m%d%H%M%S" )

#for r1 in ${INDIR}/[0-9A-F]*_R1.fastq.gz ; do
#for r1 in ${INDIR}/[G-Z]*_R1.fastq.gz ; do
#for r1 in ${INDIR}/F*_R1.fastq.gz ; do
#for r1 in ${INDIR}/02*_R1.fastq.gz ; do

#	Only want to process the ALL files at the moment so ...
while IFS=, read -r sequencing length ; do

	if [ $length -lt 100 ] ; then
		echo "Skipping ${sequencing} as length ${length} is too short"
		continue
	fi

	if [ ${sequencing:8:2} != '01' ] && [ ${sequencing:8:2} != '10' ] ; then
		echo "Skipping ${sequencing} as not 01 or 10"
		continue
	fi

	#base=${r1%_R1.fastq.gz}
	r1=${INDIR}/${sequencing}.SVAs_and_HERVs_KWHE.R1.fastq.gz
	echo $r1
	r2=${r1/.R1.fastq/.R2.fastq}

	if [ -f ${r1} ] && [ -f ${r2} ] ; then

		echo "processing"

		if [ $length -eq 101 ] ; then
			echo "Linking ${sequencing} as length ${length} is just right"
			l=${DIR}/${sequencing}.R1.fastq.gz
			if [ ! -e ${l} ] ; then
				ln -s ${r1} ${l}
			fi
			l=${DIR}/${sequencing}.R2.fastq.gz
			if [ ! -e ${l} ] ; then
				ln -s ${r2} ${l}
			fi
		else
			echo "${sequencing} length ${length} is too long. Trimming to 101."
		
			base=$( basename $r1 .SVAs_and_HERVs_KWHE.R1.fastq.gz )
			echo $base
		
			out_base=${DIR}/${base}
			f=${out_base}.R1.fastq.gz
			if [ -f $f ] && [ ! -w $f ] ; then
				echo "Write-protected $f exists. Skipping."
			else
				${sbatch} --job-name=${basename}trim --time=30 --ntasks=4 --mem=30G \
					--output=${out_base}.${r}.${date}.txt \
					~/.local/bin/cutadapt.bash --length 101 --cores 4 \
						--output ${f} --paired-output ${f/.R1/.R2} ${r1} ${r2}
			fi

		fi

	else

		echo "Input files not available yet"
		echo $r1
		echo $r2

	fi

done < sequencing_paired_read_lengths.csv
#done < <( sed 's/,/ /' read_lengths.csv )
#done

