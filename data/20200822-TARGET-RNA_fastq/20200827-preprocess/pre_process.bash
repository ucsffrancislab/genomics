#!/usr/bin/env bash

#set -x
set -e  #       exit if any command fails
set -u  #       Error on usage of unset variables
set -o pipefail


REFS=/francislab/data1/refs
FASTA=${REFS}/fasta
#KALLISTO=${REFS}/kallisto
#SUBREAD=${REFS}/subread
#BOWTIE2=${REFS}/bowtie2
#BLASTDB=${REFS}/blastn
#KRAKEN2=${REFS}/kraken2
#DIAMOND=${REFS}/diamond


#	remember 64 cores and ~504GB mem
threads=8
vmem=62


date=$( date "+%Y%m%d%H%M%S" )

IN="/francislab/data1/raw/20200822-TARGET-RNA_fastq/fastq"
OUT="/francislab/data1/working/20200822-TARGET-RNA_fastq/20200827-preprocess"
mkdir -p ${OUT}

#for r1 in ${IN}/10-PA[A-N]*_R1.fastq.gz ; do
#for r1 in ${IN}/10-PA*_R1.fastq.gz ; do

#	Only want to process the ALL files at the moment so ...
while IFS=, read -r r1 ; do

	base=${r1%_R1.fastq.gz}

	echo $base
	jobbase=$( basename ${base} )

	outbase="${OUT}/trimmed/length/unpaired/${jobbase}"
	f=${outbase}.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -N ${jobbase}.pre \
			-l feature=nocommunal \
			-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
			-j oe -o ${outbase}.pre_process.${date}.out.txt \
			~/.local/bin/pre_process_paired.bash \
				-F "-out ${OUT} -r1 ${r1}"
	fi

done < ALL-P2.fastq_files.txt

#done

