#!/usr/bin/env bash

mkdir -p ${PWD}/proteins

date=$( date "+%Y%m%d%H%M%S" )

while read -r virus ; do
	echo $virus

	for accession in $( zgrep "${virus}" /francislab/data1/refs/refseq/viral/viral.protein.faa.gz | sed 's/>//' | cut -f1 -d' ' ) ; do
		ls -1 /francislab/data1/refs/refseq/viral/split/${accession}.fa

		o=${PWD}/proteins/${accession}.faa
		if [ ! -f ${o} ] ; then
			#	7 keeps tripping out of memory in next step. So does 6, but much less.
			#faSplit -oneFile -extra=7 size /francislab/data1/refs/refseq/viral/split/${accession}.fa 7 proteins/${accession/./_}_
			faSplit -oneFile -extra=6 size /francislab/data1/refs/refseq/viral/split/${accession}.fa 6 proteins/${accession/./_}_
			mv ${PWD}/proteins/${accession/./_}_.fa ${o}
			chmod -w $o
		fi

		o=${PWD}/proteins/${accession}.fna.gz
		if [ ! -f "${o}" ] || [ -w "${o}" ] ; then
			#	takes about 2 hours
			#	Many run out of memory. Bumping up to 124 for rerun.
			${sbatch} --job-name=$(basename ${o} .fna.gz) --time=999 --ntasks=4 --mem=124G --output=${o}.${date}.txt \
				${PWD}/peptides2nucleotides.bash -o ${o} ${o%.fna.gz}.faa
		fi

#		o=${PWD}/proteins/${accession}.bam
#		if [ ! -f "${o}" ] || [ -w "${o}" ] ; then
#
#			#	SCRATCH?
#
#			echo ${sbatch} --job-name=$(basename ${o} .bam) --time=999 --ntasks=8 --mem=62G --output=${PWD}/${o}.${date}.txt ~/.local/bin/bowtie2.bash --sort --threads 8 -x /francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts --no-unal --very-sensitive --all -f -U ${o%.bam}.fna.gz -o ${o}
#
#		fi

	done

done <<EOF
Human alphaherpesvirus 3
Human gammaherpesvirus 4
EOF


