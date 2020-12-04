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
#threads=16
#vmem=125


date=$( date "+%Y%m%d%H%M%S" )

IN="/francislab/data1/raw/20201006-GTEx/fastq"
OUT="/francislab/data1/working/20201006-GTEx/20201116-preprocess"
mkdir -p ${OUT}

#for r1 in ${IN}/SRR*_R1.fastq.gz ; do

#	Only want to process the ALL files at the moment so ...
#while IFS=, read -r r1 ; do

while read -r accession ; do

	echo ${accession}

	r1=${IN}/${accession}_R1.fastq.gz

	ls $r1

	if [ -f ${r1} ] ; then

		base=${r1%_R1.fastq.gz}
	
		echo $base
		jobbase=$( basename ${base} )
	
		#	No unpairing needed so keep lane in final file check.
		outbase="${OUT}/trimmed/length/${jobbase}"
		f=${outbase}_R1.fastq.gz
		#	Unpairing needed so lose lane in final file check.
		#outbase="${OUT}/trimmed/length/unpaired/${jobbase}"
		#f=${outbase}.fastq.gz
		if [ -f $f ] && [ ! -w $f ] ; then
			echo "Write-protected $f exists. Skipping."
		else
			qsub -N ${jobbase}.pre \
				-l feature=nocommunal \
				-l nodes=1:ppn=${threads} -l vmem=${vmem}gb \
				-j oe -o ${outbase}.pre_process.${date}.out.txt \
				~/.local/bin/pre_process_paired.bash \
					-F "-out ${OUT} -r1 ${r1}"
					#-F "--unpair -out ${OUT} -r1 ${r1}"
#	--bbduk qin=33
		fi

	fi

#done < ALL-P2.fastq_files.txt
#done

#done < <( head -n 500 /francislab/data1/raw/20201006-GTEx/PairedBrainRNASRAAccessions.txt )
#done < <( head -n 1400 /francislab/data1/raw/20201006-GTEx/PairedBrainRNASRAAccessions.txt | tail -n 100 )
done < /francislab/data1/raw/20201006-GTEx/PairedBrainRNASRAAccessions.txt


