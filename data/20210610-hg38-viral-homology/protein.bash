#!/usr/bin/env bash

mkdir -p ${PWD}/proteins

date=$( date "+%Y%m%d%H%M%S" )

while read -r virus ; do
	echo $virus

	for accession in $( zgrep "${virus}" /francislab/data1/refs/refseq/viral/viral.protein.faa.gz | sed 's/>//' | cut -f1 -d' ' ) ; do
		ls -1 /francislab/data1/refs/refseq/viral/split/${accession}.fa

if [ ${accession} == 'YP_401643.1' ] ; then continue; fi

		o=${PWD}/proteins/${accession}.faa
		if [ ! -f ${o} ] ; then
			#	7 keeps tripping out of memory in next step. So does 6, but much less.
			#faSplit -oneFile -extra=7 size /francislab/data1/refs/refseq/viral/split/${accession}.fa 7 proteins/${accession/./_}_
			faSplit -oneFile -extra=6 size /francislab/data1/refs/refseq/viral/split/${accession}.fa 6 proteins/${accession/./_}_
			mv ${PWD}/proteins/${accession/./_}_.fa ${o}
			chmod -w $o
		fi

		p2n_id=""
		o=${PWD}/proteins/${accession}.fna.gz
		if [ ! -f "${o}" ] || [ -w "${o}" ] ; then
			#	takes about 2 hours
			#	Many run out of memory. Bumping up to 124 for rerun.
			#	More run out of memory. Bumping up to 248 for rerun.
			#	Several still out of memory or out of time!
			#p2n_id=$( ${sbatch} --parsable --job-name=p2n${accession} --time=999 --ntasks=8 --mem=62G --output=${o}.peptides2nucleotides.${date}.txt \
			#p2n_id=$( ${sbatch} --parsable --job-name=p2n${accession} --time=999 --ntasks=8 --mem=124G --output=${o}.peptides2nucleotides.${date}.txt \
			#p2n_id=$( ${sbatch} --parsable --job-name=p2n${accession} --time=999 --ntasks=8 --mem=248G --output=${o}.peptides2nucleotides.${date}.txt \
			#p2n_id=$( ${sbatch} --parsable --job-name=p2n${accession} --time=1999 --ntasks=8 --mem=499G --output=${o}.peptides2nucleotides.${date}.txt \
			p2n_id=$( ${sbatch} --parsable --job-name=p2n${accession} --time=2880 --ntasks=8 --mem=499G --output=${o}.peptides2nucleotides.${date}.txt \
				${PWD}/peptides2nucleotides.bash -o ${o} ${o%.fna.gz}.faa )
			echo ${p2n_id}
		fi

#	 1hr -   60
#	 4hr -  240
#	10hr -  600
#	12hr -  720
#	20hr - 1200
#	24hr - 1440
#	36hr - 2160
#	48hr - 2880

		o=${PWD}/proteins/${accession}.loc.bam
		if [ ! -f "${o}" ] || [ -w "${o}" ] ; then
			if [ ! -z "${p2n_id}" ] ; then
				depend="--dependency=afterok:${p2n_id}"
			else
				depend=""
			fi

			fasta=${o%.loc.bam}.fna.gz
			fasta_size=$( stat --dereference --format %s ${fasta} 2> /dev/null || echo 13575438589 ) #	 13 575 438 589 was largest I saw

			index=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts
			index_size=$( stat --dereference --format %s ${index}.?.bt2 ${index}.rev.?.bt2 | awk '{s+=$1}END{print s}' )

			#scratch=$( echo $(( ((2*(${r1_size}+${r2_size})+${index_size})/${threads}/1000000000)+1 )) )
			#	c4 doesn't do thread-based scratch calculation. just job.
			scratch=$( echo $(( ((2*(${fasta_size})+${index_size})/1000000000)+1 )) )
			#	Add 1 in case files are small so scratch will be 1 instead of 0.
			#	11/10 adds 10% to account for the output

			echo "Using scratch:${scratch}"

			${sbatch} ${depend} --time=1440 --job-name=btl${accession} --ntasks=8 --mem=62G \
				--gres=scratch:${scratch}G \
				--output=${o}.bowtie2hg38.${date}.txt \
				~/.local/bin/bowtie2_scratch.bash --sort --threads 8 \
					-x ${index} --no-unal --very-sensitive-local --all -f -U ${o%.loc.bam}.fna.gz -o ${o}

		fi

		o=${PWD}/proteins/${accession}.e2e.bam
		if [ ! -f "${o}" ] || [ -w "${o}" ] ; then
			if [ ! -z "${p2n_id}" ] ; then
				depend="--dependency=afterok:${p2n_id}"
			else
				depend=""
			fi

			fasta=${o%.e2e.bam}.fna.gz
			fasta_size=$( stat --dereference --format %s ${fasta} 2> /dev/null || echo 13575438589 ) #	 13 575 438 589 was largest I saw

			index=/francislab/data1/refs/sources/hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.chrXYM_no_alts
			index_size=$( stat --dereference --format %s ${index}.?.bt2 ${index}.rev.?.bt2 | awk '{s+=$1}END{print s}' )

			#scratch=$( echo $(( ((2*(${r1_size}+${r2_size})+${index_size})/${threads}/1000000000)+1 )) )
			#	c4 doesn't do thread-based scratch calculation. just job.
			scratch=$( echo $(( ((2*(${fasta_size})+${index_size})/1000000000)+1 )) )
			#	Add 1 in case files are small so scratch will be 1 instead of 0.
			#	11/10 adds 10% to account for the output

			echo "Using scratch:${scratch}"

			${sbatch} ${depend} --time=1440 --job-name=bte${accession} --ntasks=8 --mem=62G \
				--gres=scratch:${scratch}G \
				--output=${o}.bowtie2hg38.${date}.txt \
				~/.local/bin/bowtie2_scratch.bash --sort --threads 8 \
					-x ${index} --no-unal --very-sensitive --all -f -U ${o%.e2e.bam}.fna.gz -o ${o}

		fi


	done

done <<EOF
Human alphaherpesvirus 3
Human gammaherpesvirus 4
EOF


