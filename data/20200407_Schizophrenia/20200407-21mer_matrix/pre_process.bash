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

threads=8

date=$( date "+%Y%m%d%H%M%S" )


IN=/francislab/data1/raw/20200407_Schizophrenia/fastq/
OUT=/francislab/data1/working/20200407_Schizophrenia/20200407-21mer_matrix/	#trimmed
mkdir -p ${OUT}

for r1 in ${IN}/????_R1.fastq.gz ; do

	base=${r1%_R1.fastq.gz}
	#r2=${r1/_R1/_R2}

	echo $base
	jobbase=$( basename ${base} )

	outbase="${OUT}/trimmed/length/unpaired/${jobbase}"
	f=${outbase}.fastq.gz
	if [ -f $f ] && [ ! -w $f ] ; then
		echo "Write-protected $f exists. Skipping."
	else
		qsub -N ${jobbase}.pre \
			-l nodes=1:ppn=8 -l vmem=32gb \
			-j oe -o ${outbase}.pre_process.${date}.out.txt \
			~/.local/bin/pre_process_paired.bash \
				-F "-out ${OUT} -r1 ${r1}"
	fi

done

